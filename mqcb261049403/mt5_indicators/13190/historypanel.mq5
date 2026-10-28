//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright     "Serhiy Dotsenko"
#property link          "https://www.mql5.com/ru/users/thejobber"
#property version       "1.000"
#property description   "aggregated trade statistics"
#property description   " "
#property description   "агрегированная статистика торговли"
#property indicator_plots               0
//---
#include <Trade\DealInfo.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\Dialog.mqh>
#include <Tools\DateTime.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDeal
  {
private:
   ulong             m_ticket;
   datetime          m_date;
   string            m_symbol;
   ulong             m_magic;
   float             m_plMoney;
   float             m_swap;
   float             m_commission;
   int               m_plPointsWithOutSwapsComm;
   //---
public:
                     CDeal();
                     CDeal(ulong ticket,datetime date,string symbol,ulong magic,float profit,float swap,float commission,int profitPoints);
   void              Ticket(ulong ticket);
   ulong             Ticket();
   void              Date(datetime date);
   datetime          Date();
   void              Sumbol(string symbol);
   string            Sumbol();
   void              Magic(ulong magic);
   ulong             Magic();
   void              Profit(float profit);
   float             Profit();
   void              Swap(float swap);
   float             Swap();
   void              Commission(float commission);
   float             Commission();
   void              Points(int points);
   int               Points();
  };
//---
CDeal::CDeal(){}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::CDeal(ulong ticket,datetime date,string symbol,ulong magic,float profit,float swap,float commission,int profitPoints)
  {
   m_ticket=ticket;
   m_date=date;
   m_symbol=symbol;
   m_magic=magic;
   m_plMoney=profit;
   m_swap=swap;
   m_commission=commission;
   m_plPointsWithOutSwapsComm=profitPoints;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Ticket(ulong ticket)
  {
   m_ticket=ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CDeal::Ticket()
  {
   return m_ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Date(datetime date)
  {
   m_date=date;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CDeal::Date()
  {
   return m_date;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Sumbol(string symbol)
  {
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDeal::Sumbol()
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Magic(ulong magic)
  {
   m_magic=magic;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CDeal::Magic()
  {
   return m_magic;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Profit(float profit)
  {
   m_plMoney=profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CDeal::Profit(void)
  {
   return m_plMoney;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Swap(float swap)
  {
   m_swap=swap;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CDeal::Swap(void)
  {
   return m_swap;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Commission(float commission)
  {
   m_commission=commission;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CDeal::Commission(void)
  {
   return m_commission;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::Points(int points)
  {
   m_plPointsWithOutSwapsComm=points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDeal::Points(void)
  {
   return m_plPointsWithOutSwapsComm;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDeals
  {
private:
   CDeal             m_deals[];
   CArrayLong        m_uniqMagics;
   CArrayString      m_uniqSymbols;
   CDateTime         m_uniqDates[];
   void              updateArraySize(CDeal &array[],int currentIndex);//todo переписать что бы можно было любого типа массив принимать
   void              updateArraySizeDate(CDateTime  &array[],int index);
   int               calcFinResPoints(ulong initialDeal,ulong currentDeal,float pl,string symbol);
   void              storeUniqSymbols(datetime startDate,datetime finishDate);
   void              storeUniqMagics(datetime startDate,datetime finishDate);
   void              storeUniqDates(datetime date);
   bool              findDate(datetime date);
   //---
public:
                     CDeals();
   float             getFinResCurrency(datetime startDate,datetime finishDate,string symbol,ulong magic);
   int               getFinResPointsWithOutCommissionSwaps(datetime startDate,datetime finishDate,string symbol,ulong magic);
   CArrayString     *getUniqSymbols();
   CArrayLong       *getUniqMagics();
   CDateTime         getUniqDateByIndex(int index);
   int               getUniqDateArrayLen();
   int               getDealsArrayLen();
   CDeal            *getDealByIndex(int index);
   //--- проверочные функции, можно удалить, если что...        
   void              printAllUniqDates();
   void              printAllDials();
  };
//---
CDeals::printAllUniqDates()
  {
   for(int i=ArraySize(m_uniqDates)-1;i>=0;i--)
     {
      Print(TimeToString(m_uniqDates[i].DateTime(),TIME_DATE));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDeals::findDate(datetime date)
  {
   CDateTime currentDate;
   currentDate.Date(date);
   for(int i=ArraySize(m_uniqDates)-1;i>=0;i--)
     {
      if(currentDate.day==m_uniqDates[i].day && currentDate.mon==m_uniqDates[i].mon && currentDate.year==m_uniqDates[i].year)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::updateArraySize(CDeal &array[],int currentIndex)
  {
   int currenArraySize=ArraySize(array)-1;
   if(currentIndex>currenArraySize)
      ArrayResize(array,currenArraySize+10,10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::updateArraySizeDate(CDateTime &array[],int index)
  {
   int currentArraySize=ArraySize(array)-1;
   if(index>currentArraySize)
      ArrayResize(array,currentArraySize+10,10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::printAllDials()
  {
   for(int i=ArraySize(m_deals)-1; i>=0; i--)
      PrintFormat("ticker %d, profit %f, symbol %s, magic %d",m_deals[i].Ticket(),m_deals[i].Profit(),m_deals[i].Sumbol(),m_deals[i].Magic());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::CDeals()
  {
   CDealInfo dInfo;
   HistorySelect(0,TimeCurrent());
   int totalHistoryDeals=HistoryDealsTotal();
   for(int i=0,j=0; i<totalHistoryDeals; i++)
     {
      if(HistorySelect(0,TimeCurrent()) && dInfo.SelectByIndex(i) && HistorySelectByPosition(dInfo.PositionId()) && dInfo.Entry()==DEAL_ENTRY_OUT)
        {
         ulong initialTicket=HistoryDealGetTicket(0);
         ulong initialTicketMagic=HistoryDealGetInteger(initialTicket,DEAL_MAGIC);
         updateArraySize(m_deals,j);
         m_deals[j].Commission((float)dInfo.Commission());
         m_deals[j].Date(dInfo.Time());
         m_deals[j].Magic(initialTicketMagic);
         m_deals[j].Points(calcFinResPoints(initialTicket,dInfo.Ticket(),(float)dInfo.Profit(),dInfo.Symbol()));
         m_deals[j].Profit((float)dInfo.Profit());
         m_deals[j].Sumbol(dInfo.Symbol());
         m_deals[j].Swap((float)dInfo.Swap());
         m_deals[j].Ticket(dInfo.Ticket());
         storeUniqDates(dInfo.Time());
         j+=1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDeals::calcFinResPoints(ulong initialDeal,ulong currentDeal,float pl,string symbol)
  {
   CSymbolInfo sInfo;
   sInfo.Name(symbol);
   sInfo.Refresh();
   double currentFinResPoints=MathAbs(HistoryDealGetDouble(initialDeal,DEAL_PRICE)-HistoryDealGetDouble(currentDeal,DEAL_PRICE));
   if(pl<0)
      currentFinResPoints*=-1;
   return (int)(NormalizeDouble( currentFinResPoints, sInfo.Digits()) / sInfo.TickSize());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CDeals::getFinResCurrency(datetime startDate,datetime finishDate,string symbol,ulong magic)
  {
   CDateTime localFinishDate;
   localFinishDate.Date(finishDate);
   localFinishDate.Hour(23);
   localFinishDate.Min(59);
   localFinishDate.Sec(59);
   float finResCurrency=0;
   for(int i=ArraySize(m_deals)-1; i>=0; i--)
     {
      ulong mag= m_deals[i].Ticket();
      float pl = m_deals[i].Profit();
      datetime d1 = m_deals[i].Date();
      datetime d2 = localFinishDate.DateTime();
      string s1=m_deals[i].Sumbol();
      ulong m=m_deals[i].Magic();

      if(m_deals[i].Date()>=startDate && m_deals[i].Date()<=localFinishDate.DateTime() && m_deals[i].Sumbol()==symbol && m_deals[i].Magic()==magic)
        {
         finResCurrency+=m_deals[i].Profit()+m_deals[i].Swap()+m_deals[i].Commission();
        }
     }
   return finResCurrency;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDeals::getFinResPointsWithOutCommissionSwaps(datetime startDate,datetime finishDate,string symbol,ulong magic)
  {
   CDateTime localFinishDate;
   localFinishDate.Date(finishDate);
   localFinishDate.Hour(23);
   localFinishDate.Min(59);
   localFinishDate.Sec(59);
   int finResPointsWithOutCommissionSwaps=0;
   for(int i=ArraySize(m_deals)-1; i>=0; i--)
     {
      if(m_deals[i].Date()>=startDate && m_deals[i].Date()<=localFinishDate.DateTime() && m_deals[i].Sumbol()==symbol && m_deals[i].Magic()==magic)
        {
         finResPointsWithOutCommissionSwaps+=m_deals[i].Points();
        }
     }
   return finResPointsWithOutCommissionSwaps;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::storeUniqDates(datetime date)
  {
   static int j=0;
   if(!findDate(date))
     {
      updateArraySizeDate(m_uniqDates,j);
      m_uniqDates[j].Date(date);
      j+=1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::storeUniqSymbols(datetime startDate,datetime finishDate)
  {
   if(m_uniqSymbols.Shutdown())
     {
      for(int i=ArraySize(m_deals)-1; i>=0; i --)
        {
         if(m_deals[i].Date()>=startDate && m_deals[i].Date()<=finishDate && m_uniqSymbols.SearchLinear(m_deals[i].Sumbol())==-1)
           {
            m_uniqSymbols.Add(m_deals[i].Sumbol());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CArrayString *CDeals::getUniqSymbols()
  {
   storeUniqSymbols(0,TimeCurrent());
   return GetPointer(m_uniqSymbols);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeals::storeUniqMagics(datetime startDate,datetime finishDate)
  {
   if(m_uniqMagics.Shutdown())
     {
      for(int i=ArraySize(m_deals)-1; i>=0; i--)
        {
         if(m_deals[i].Date()>=startDate && m_deals[i].Date()<=finishDate && m_uniqMagics.SearchLinear(m_deals[i].Magic())==-1)
           {
            m_uniqMagics.Add(m_deals[i].Magic());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CArrayLong *CDeals::getUniqMagics()
  {
   storeUniqMagics(0,TimeCurrent());
   return GetPointer(m_uniqMagics);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDeals::getUniqDateArrayLen()
  {
   return ArraySize(m_uniqDates);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDateTime CDeals::getUniqDateByIndex(int index)
  {
   return m_uniqDates[index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDeals::getDealsArrayLen()
  {
   return ArraySize(m_deals);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal *CDeals::getDealByIndex(int index)
  {
   return GetPointer(m_deals[index]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
   //---
private:
   CListView         m_list_view;
   CDeals            m_deals;
   CComboBox         m_magics;
   CComboBox         m_startDate;
   CComboBox         m_endDate;
   //---
public:
                     CPanelDialog(void);
                    ~CPanelDialog(void);
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
protected:
   bool              CreateListView();
   bool              CreateMagicsComboBox();
   bool              CreateStartDateComboBox();
   bool              CreateEndDateComboBox();
   bool              FillMagics();
   bool              FillStartDate();
   bool              FillEndDate(datetime date=0);
   bool              FillEndDate(string date);
   bool              FillListView();
   void              OnChangeMagics();
   void              OnChangeStartDate();
   void              OnChangeEndDate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPanelDialog)
ON_EVENT(ON_CHANGE,m_magics,OnChangeMagics)
ON_EVENT(ON_CHANGE,m_startDate,OnChangeStartDate)
ON_EVENT(ON_CHANGE,m_endDate,OnChangeEndDate)
EVENT_MAP_END(CAppDialog)

void CPanelDialog::OnChangeMagics()
  {
   FillListView();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::OnChangeStartDate()
  {
//FillEndDate(m_startDate.Select());
   FillListView();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::OnChangeEndDate()
  {
   FillListView();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::FillMagics()
  {
   for(int i=0;m_magics.ItemDelete(i);i++);
   CArrayLong *magics=m_deals.getUniqMagics();
   for(int i=magics.Total()-1; i>=0; i--)
     {
      m_magics.ItemAdd((string)magics.At(i),i);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::FillStartDate()
  {
   for(int i=0;m_startDate.ItemDelete(i);i++);
   for(int i=m_deals.getUniqDateArrayLen()-1;i>=0;i--)
     {
      if(m_deals.getUniqDateByIndex(i).DateTime()<=TimeCurrent() && m_deals.getUniqDateByIndex(i).DateTime()>0)
         m_startDate.ItemAdd(TimeToString(m_deals.getUniqDateByIndex(i).DateTime(),TIME_DATE),i);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::FillEndDate(datetime date)
  {
   for(int i=m_endDate.ControlsTotal()-1;i>=0;i--)
     {
      m_endDate.ItemDelete(i);
     }
   for(int i=m_deals.getUniqDateArrayLen()-1;i>=0;i--)
     {
      if(m_deals.getUniqDateByIndex(i).DateTime()>=date && m_deals.getUniqDateByIndex(i).DateTime()<=TimeCurrent())
         m_endDate.ItemAdd(TimeToString(m_deals.getUniqDateByIndex(i).DateTime(),TIME_DATE),i);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::FillEndDate(string date)
  {
   for(int i=m_endDate.ControlsTotal()-1;i>=0;i--)
     {
      m_endDate.ItemDelete(i);
     }
   for(int i=m_deals.getUniqDateArrayLen()-1;i>=0;i--)
     {
      if(m_deals.getUniqDateByIndex(i).DateTime()>=StringToTime(date) && m_deals.getUniqDateByIndex(i).DateTime()<=TimeCurrent())
         m_endDate.ItemAdd(TimeToString(m_deals.getUniqDateByIndex(i).DateTime(),TIME_DATE),i);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::FillListView()
  {
   for(int i=m_list_view.ControlsTotal()-1;i>=0;i--)
      m_list_view.ItemDelete(i);
   CArrayString *symbols=m_deals.getUniqSymbols();
   datetime startDate=StringToTime(m_startDate.Select());
   datetime endDate=StringToTime(m_endDate.Select());
   long magic=StringToInteger(m_magics.Select());
   float totalfinResCurr=0;
   for(int i=symbols.Total()-1;i>=0;i--)
     {
      float finResCurr=m_deals.getFinResCurrency(startDate,endDate,symbols.At(i),magic);
      if(finResCurr)
        {
         m_list_view.ItemAdd(StringFormat("%s: %15.2f %14i",symbols.At(i),finResCurr,m_deals.getFinResPointsWithOutCommissionSwaps(startDate,endDate,symbols.At(i),magic)));
         totalfinResCurr+=finResCurr;
        }
     }
   m_list_view.ItemAdd("");
   m_list_view.ItemAdd(StringFormat("TOTAL: %16.2f",totalfinResCurr));
   return true;
  }
//---
CPanelDialog::CPanelDialog(){}
//---
CPanelDialog::~CPanelDialog(){}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   return CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)
   && CreateMagicsComboBox()
   && CreateStartDateComboBox()
   && CreateEndDateComboBox()
   && CreateListView()
   ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateMagicsComboBox()
  {
   return m_magics.Create(0,"magic combo",0,10,10,60,30) && Add(m_magics) && FillMagics() && m_magics.Select(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateStartDateComboBox()
  {
   return m_startDate.Create(0,"start date combo",0,70,10,170,30) && Add(m_startDate) && FillStartDate() && m_startDate.Select(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateEndDateComboBox()
  {
   return m_endDate.Create(0,"end date combo",0,180,10,280,30) && Add(m_endDate) && FillEndDate() && m_endDate.Select(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateListView()
  {
   return m_list_view.Create(0,"list",0,10,40,280,240) && Add(m_list_view) && FillListView();
  }
//---
CPanelDialog ExtDialog;
//---
int      panelXX     =  20;
int      panelYY     =  20;
int      panelWidth  =  320;
int      panelHeight =  300;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(ExtDialog.Create(0,"trading results",0,panelXX,panelYY,panelWidth,panelHeight) && ExtDialog.Run())
      return(INIT_SUCCEEDED);
   return(INIT_FAILED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtDialog.Destroy(reason);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
