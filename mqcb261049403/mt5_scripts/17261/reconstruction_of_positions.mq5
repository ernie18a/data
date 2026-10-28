//+------------------------------------------------------------------+
//|                                 Reconstruction of positions.mq5  |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#include <Arrays\ArrayObj.mqh> 
#property description "Реконструкция ПОЗИЦИЙ из истории сделок"
#property script_show_inputs
//---
input datetime start=D'2016.12.22 16:17:00';
//+------------------------------------------------------------------+ 
//| Класс - позиция - совокупность всех сделок                       |
//| с одинаковым POSITION_ID                                         | 
//+------------------------------------------------------------------+ 
class CMyPosition : public CArrayObj
  {
private:
   long              m_pos_id;            // идентификатор позиции, в открытии, изменении или закрытии которой участвовала эта сделка
public:
   // CMyPosition(void);
   //~CMyPosition(void);
   //--- методы доступа к защищённым данным
   void              ID(const long value) { m_pos_id=value;               }
   long              ID(void) const       { return(m_pos_id);             }
  };
//+------------------------------------------------------------------+ 
//| Класс - сделка                                                   | 
//+------------------------------------------------------------------+ 
class CMyDeal : public CObject
  {
private:
   long              m_deal_entry;        // направление сделки – вход в рынок, выход из рынка или разворот
   long              m_deal_type;         // тип сделки
   double            m_deal_price;        // цена сделки
   double            m_deal_volume;       // объём сделки
   long              m_deal_id;           // идентификатор позиции, в открытии, изменении или закрытии которой участвовала эта сделка
   double            m_deal_profit;       // финансовый результат сделки 
public:
                     CMyDeal(void);
                    ~CMyDeal(void);
   //--- методы доступа к защищённым данным
   void              Entry_deal(const long value)    { m_deal_entry=value;               }
   long              Entry_deal(void) const          { return(m_deal_entry);             }

   void              Type_deal(const long value)     { m_deal_type=value;                }
   long              Type_deal(void) const           { return(m_deal_type);              }

   void              Price_deal(const double value)  { m_deal_price=value;               }
   double            Price_deal(void) const          { return(m_deal_price);             }

   void              Volume_deal(const double value) { m_deal_volume=value;              }
   double            Volume_deal(void) const         { return(m_deal_volume);            }

   void              ID_deal(const long value)       { m_deal_id=value;                  }
   long              ID_deal(void) const             { return(m_deal_id);                }

   void              Profit_deal(const double value) { m_deal_profit=value;              }
   double            Profit_deal(void) const         { return(m_deal_profit);            }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMyDeal::CMyDeal(void) : m_deal_entry(0),
                         m_deal_type(0),
                         m_deal_price(0.0),
                         m_deal_volume(0.0),
                         m_deal_id(0),
                         m_deal_profit(0.0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMyDeal::~CMyDeal(void)
  {
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("This script can be started only on a hedge; Этот скрипт можно запускать только на хедж");
      return;
     }
   Print_IDs();
  }
//+------------------------------------------------------------------+
//| List all positions and deals                                     |
//+------------------------------------------------------------------+
void Print_IDs(void)
  {
   CArrayObj arr_positions;                  // объкт динамического массива указателей

//--- запрашиваем историю сделок и ордеров за указанный период серверного времени
   HistorySelect(start,TimeCurrent()+86400);
   uint     total    =HistoryDealsTotal();   // количество сделок в истории
   ulong    ticket   =0;                     // тикет сделки в истории
   long     magic    =0;
   long     type     =0;                     // тип сделки
   long     deal_id  =0;                     // идентификатор позиции, в открытии, изменении или закрытии которой участвовала эта сделка
   double   volume   =0.0;                   // объём сделки
   double   profit   =0.0;                   // финансовый результат сделки
   double   price    =0.0;                   // цена сделки
   string   symbol   =NULL;                  // имя символа, по которому произведена сделка
   long     entry    =0;                     // направление сделки – вход в рынок, выход из рынка или разворот
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         magic    =HistoryDealGetInteger(ticket,DEAL_MAGIC);
         type     =HistoryDealGetInteger(ticket,DEAL_TYPE);
         deal_id  =HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
         volume   =HistoryDealGetDouble(ticket,DEAL_VOLUME);
         profit   =HistoryDealGetDouble(ticket,DEAL_PROFIT);
         price    =HistoryDealGetDouble(ticket,DEAL_PRICE);
         symbol   =HistoryDealGetString(ticket,DEAL_SYMBOL);
         entry    =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(symbol==Symbol() /*&& magic==m_magic*/)
           {
            bool find=false;
            for(int j=0;j<arr_positions.Total();j++)
              {
               //--- объявим указатель на объект класса CMyPosition и присвоим ему элемент из указанной позиции массива  
               CMyPosition *my_position=arr_positions.At(j);

               if(my_position==NULL)
                 {
                  //--- ошибка чтения из массива
                  Print("Get element error (\"arr_positions\")");
                  return;
                 }
               if(my_position.ID()==deal_id)
                 {
                  find=true;
                  //--- объявим указатель на объект класса CMyDeal и присвоим ему вновь созданный объект класса CMyDeal
                  CMyDeal *my_deal=new CMyDeal;
                  if(my_deal==NULL)
                    {
                     //--- ошибка создания
                     Print("Object create error (\"my_deal\")");
                     return;
                    }
                  my_deal.Entry_deal(entry);
                  my_deal.Type_deal(type);
                  my_deal.Price_deal(price);
                  my_deal.Volume_deal(volume);
                  my_deal.ID_deal(deal_id);
                  my_deal.Profit_deal(profit);

                  my_position.Add(my_deal);
                 }
              }
            if(!find)
              {
               //--- объявим указатель на объект класса CMyPosition и присвоим ему вновь созданный объект класса CMyPosition 
               CMyPosition *my_position=new CMyPosition;
               if(my_position==NULL)
                 {
                  //--- ошибка создания
                  Print("Object create error (\"arr_positions\")");
                  return;
                 }
               my_position.ID(deal_id);
               //--- объявим указатель на объект класса CMyDeal и присвоим ему вновь созданный объект класса CMyDeal
               CMyDeal *my_deal=new CMyDeal;
               if(my_deal==NULL)
                 {
                  //--- ошибка создания
                  Print("Object create error (\"my_deal\")");
                  return;
                 }
               my_deal.Entry_deal(entry);
               my_deal.Type_deal(type);
               my_deal.Price_deal(price);
               my_deal.Volume_deal(volume);
               my_deal.ID_deal(deal_id);
               my_deal.Profit_deal(profit);

               my_position.Add(my_deal);

               arr_positions.Add(my_position);
              }
           }
        }
     }
   for(int k=0;k<arr_positions.Total();k++)
     {
      //--- объявим указатель на объект класса CMyPosition и присвоим ему элемент из указанной позиции массива 
      CMyPosition *my_position=arr_positions.At(k);
      if(my_position==NULL)
        {
         //--- ошибка чтения из массива 
         Print("Get element error (\"arr_positions\")");
         return;
        }
      Print("position #",k);
      for(int m=0;m<my_position.Total();m++)
        {
         //--- объявим указатель на объект класса CMyDeal и присвоим ему элемент из указанной позиции массива 
         CMyDeal *my_deal=my_position.At(m);
         if(my_deal==NULL)
           {
            //--- ошибка чтения из массива 
            Print("Get element error (\"my_deal\")");
            return;
           }
         Print(EnumToString((ENUM_DEAL_ENTRY)my_deal.Entry_deal()),
               ", type ",EnumToString((ENUM_DEAL_TYPE)my_deal.Type_deal()),
               ", price ",DoubleToString(my_deal.Price_deal(),Digits()),
               ", Deal ",Symbol(),
               ", volume ",DoubleToString(my_deal.Volume_deal(),2),
               ", DEAL_POSITION_ID #",my_deal.ID_deal(),
               ", profit ",DoubleToString(my_deal.Profit_deal(),2));
        }
     }
   Print("");
  }
//+------------------------------------------------------------------+
