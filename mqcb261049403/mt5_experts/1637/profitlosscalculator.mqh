//+------------------------------------------------------------------+
//|                                         ProfitLossCalculator.mqh |
//|                                             Copyright 2013, Rone |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone"
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Profit Loss Calculator"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\RadioButton.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\Edit.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <Trade\SymbolInfo.mqh>

#include "DoubleSpinEdit.mqh"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//---
#define CONTROLS_WIDTH                      (70)
#define CONTROLS_HEIGHT                     (20)
#define EDIT_WIDTH                          (80)
//---
#define FIELDS_TOTAL                        (6)
#define LINES_TOTAL                         (3)
#define RADIO_TOTAL                         (2)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EDIT_ALIAS {
   ENTRY_EDIT = 0,
   LOT_EDIT = 1,
   LOSS_PIPS_EDIT = 2,
   PROFIT_PIPS_EDIT = 3,
   LOSS_MONEY_EDIT = 4,
   PROFIT_MONEY_EDIT = 5
};
enum LINE_ALIAS {
   ENTRY_LINE = 0,
   LOSS_LINE = 1,
   PROFIT_LINE = 2
};
//---
string label_name[FIELDS_TOTAL] = {
   "EntryLabel", "LotLabel", "LossPipsLabel", "ProfitPipsLabel", "LossMoneyLabel", "ProfitMoneyLabel"
};
string label_text[FIELDS_TOTAL] = {
   "Entry:", "Lot:", "Loss, pips:", "Profit, pips:", "Loss, ", "Profit, "
};
string spinedit_name[FIELDS_TOTAL] = {
   "EntryEdit", "LotEdit", "LossPipsEdit", "ProfitPipsEdit", "LossMoneyEdit", "ProfitMoneyEdit"
};
string line_name[LINES_TOTAL] = { "PLC_EntryLine", "PLC_LossLine", "PLC_ProfitLine" };
color line_color[LINES_TOTAL] = { clrOrange, clrRed, clrGreen };
string radio_name[RADIO_TOTAL] = { "Buy", "Sell" };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProfitLossCalculator : public CAppDialog {
private:
   CSymbolInfo       m_sym;
   long              m_order_type;
   double            m_entry_price;
   double            m_stop_price;
   double            m_profit_price;
   double            m_lot_value;
   //---
   CRadioButton      m_type_radio[RADIO_TOTAL];
   CButton           m_reset_button;
   CLabel            m_label[FIELDS_TOTAL];
   CDoubleSpinEdit   m_spinedit[FIELDS_TOTAL];
   CChartObjectHLine m_line[LINES_TOTAL];
       
public:
                     CProfitLossCalculator();
                    ~CProfitLossCalculator();
   virtual bool      Create(const long chart, const string name, const int subwin,
                            const int x1, const int y1, const int x2, const int y2);
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   virtual bool      OnEventLine(const int id, const long &lparam, const double &dparam, const string &sparam);

protected:
   //--- create lines and controls
   bool              CreateLines();
   bool              CreateRadioButtons();
   bool              CreateResetButton();
   bool              CreateLabels();
   bool              CreateDoubleSpinEdits();
   //--- handlers of the dependent controls events
   bool              OnChangeType(int index);
   bool              OnChangeDoubleSpinEdit(int index);
   
   void              OnChangeEntry();
   void              OnChangeLot();
   void              OnChangeLossPips();
   void              OnChangeProfitPips();
   void              OnChangeLossMoney();
   void              OnChangeProfitMoney();
   
   void              OnChangeEntryLine();
   void              OnChangeLossLine();
   void              OnChangeProfitLine();
   
   //---
   void              ResetData();
   void              UpdateProfitLoss();
   int               LossPips();
   int               MaxLossPips();
   int               ProfitPips();
   int               MaxProfitPips();
   double            CalculateMoney(double exit_price);
   double            LossMoney();
   double            MinLossMoney();
   double            MaxLossMoney();
   double            ProfitMoney();
   double            MinProfitMoney();
   double            MaxProfitMoney();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProfitLossCalculator::CProfitLossCalculator() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProfitLossCalculator::~CProfitLossCalculator(){
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CProfitLossCalculator)
   ON_INDEXED_EVENT(ON_CHANGE, m_type_radio, OnChangeType)
   ON_EVENT(ON_CLICK, m_reset_button, ResetData)
   ON_INDEXED_EVENT(ON_CHANGE, m_spinedit, OnChangeDoubleSpinEdit)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::Create(const long chart, const string name, const int subwin,
                                   const int x1, const int y1, const int x2, const int y2)
{
//---
   bool ok = true;
   
   ok &= CreateLines();
   ok &= CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2);
   ok &= CreateRadioButtons();
   ok &= CreateResetButton();
   ok &= CreateLabels();
   ok &= CreateDoubleSpinEdits();
   
   ResetData();
//---
   return(ok);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::CreateLines(void) {
//---
   bool ok = true;
   
   for ( int i = 0; i < LINES_TOTAL; i++ ) {
      if ( ObjectFind(0, line_name[i]) < 0 ) {    
         ok = m_line[i].Create(0, line_name[i], 0, 0.0);
         ok &= m_line[i].Color(line_color[i]);
         ok &= m_line[i].Selectable(true);
         if ( !ok ) {
            return(false);
         } 
      }
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::CreateRadioButtons(void) {
//---
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP;
   int x2 = x1 + CONTROLS_WIDTH;
   int y2 = y1 + CONTROLS_HEIGHT;
   bool ok = true;
   
   for ( int i = 0; i < RADIO_TOTAL; i++ ) {
      ok = m_type_radio[i].Create(m_chart_id, m_name+radio_name[i], m_subwin, x1, y1, x2, y2);
      ok &= m_type_radio[i].Text(radio_name[i]);
      ok &= Add(m_type_radio[i]);
      if ( !ok ) {
         return(false);
      }
      x1 = x2 + CONTROLS_GAP_X;
      x2 = x1 + CONTROLS_WIDTH;
   }
   ok &= m_type_radio[0].State(true);
//---
   return(ok);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::CreateResetButton(void) {
//---
   int x1 = INDENT_LEFT + 2 * CONTROLS_WIDTH + 3 * CONTROLS_GAP_X + EDIT_WIDTH;
   int y1 = INDENT_TOP;
   int x2 = x1 + EDIT_WIDTH;
   int y2 = y1 + CONTROLS_HEIGHT;
   bool ok = m_reset_button.Create(m_chart_id, m_name+"ResetButton", m_subwin, x1, y1, x2, y2);
   
   ok &= m_reset_button.Text("Reset");
   ok &= Add(m_reset_button); 
//---
   return(ok);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::CreateLabels(void) {
//---
   int x1, x2, y1, y2;
   bool ok = true;
   string currency = AccountInfoString(ACCOUNT_CURRENCY);
   
   for ( int row = 1, index = 0; row <= 3; row++ ) {
      y1 = INDENT_TOP + row * (CONTROLS_HEIGHT + CONTROLS_GAP_Y);
      y2 = y1 + CONTROLS_HEIGHT;
      
      for ( int col = 0; col < 2; col++ ) {
         x1 = INDENT_LEFT + col * (CONTROLS_WIDTH + EDIT_WIDTH + 2 * CONTROLS_GAP_X);
         x2 = x1 + CONTROLS_WIDTH;
         
         string text = label_text[index];
         if ( index == LOSS_MONEY_EDIT || index == PROFIT_MONEY_EDIT ) {
            text += currency + ":";
         }
         
         ok &= m_label[index].Create(m_chart_id, m_name+label_name[index], m_subwin, x1, y1, x2, y2);
         ok &= m_label[index].Text(text);
         ok &= Add(m_label[index]);
         if ( !ok ) {
            return(false);
         }
         index += 1;
      }
   }
//---
   return(ok);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::CreateDoubleSpinEdits(void) {
//---
   int x1, x2, y1, y2;
   bool ok = true;
   
   for ( int row = 1, index = 0; row <= 3; row++ ) {
      y1 = INDENT_TOP + row * (CONTROLS_HEIGHT + CONTROLS_GAP_Y);
      y2 = y1 + CONTROLS_HEIGHT;
      
      for ( int col = 0; col < 2; col++ ) {
         x1 = INDENT_LEFT + CONTROLS_WIDTH + CONTROLS_GAP_X
            + col * (CONTROLS_WIDTH + EDIT_WIDTH + 2 * CONTROLS_GAP_X);
         x2 = x1 + EDIT_WIDTH;
         
         ok &= m_spinedit[index].Create(m_chart_id, m_name+spinedit_name[index], m_subwin, x1, y1, x2, y2);
         ok &= m_spinedit[index].ReadOnly(false);
         ok &= Add(m_spinedit[index]);
         if ( !ok ) {
            return(false);
         }
         index += 1;
      }
   }
//---
   return(ok);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::ResetData(void) {
//---
   bool ok = false;
   double min_price = 0.0, max_price = 0.0;
   
   m_sym.Name(_Symbol);
   
   for ( int tries = 1; tries < 5; tries++ ) {
      if ( m_sym.IsSynchronized() && m_sym.Refresh()
         && ChartGetDouble(m_chart_id, CHART_PRICE_MIN, m_subwin, min_price)
         && ChartGetDouble(m_chart_id, CHART_PRICE_MAX, m_subwin, max_price) )
      {
         ok = true;
         break;
      }
      Sleep(1000);
   }
   
   if ( ok ) {
      //--- members
      m_order_type = (long)ORDER_TYPE_BUY;
      m_entry_price = NormalizeDouble((max_price+min_price)/2, m_sym.Digits());
      m_stop_price = NormalizeDouble(m_entry_price-(m_entry_price-min_price)/2, m_sym.Digits());
      m_profit_price = NormalizeDouble(max_price-(max_price-m_entry_price)/2, m_sym.Digits());
      m_lot_value = NormalizeDouble(10*m_sym.LotsMin(), 2);
      
      //--- lines
      m_line[ENTRY_LINE].Price(0, m_entry_price);
      m_line[LOSS_LINE].Price(0, m_stop_price);
      m_line[PROFIT_LINE].Price(0, m_profit_price);
      for ( int i = 0; i < LINES_TOTAL; i++ ) {
         m_line[i].Selected(false);
      }
      //--- controls
      m_type_radio[0].State(true);
      m_type_radio[1].State(false);
      m_spinedit[ENTRY_EDIT].SetParameters(m_entry_price, min_price, max_price, 100*m_sym.TickSize(), m_sym.Digits());
      m_spinedit[LOT_EDIT].SetParameters(m_lot_value, m_sym.LotsMin(), m_sym.LotsMax(), 10*m_sym.LotsStep(),
                           (int)NormalizeDouble(MathCeil(MathLog10(1/m_sym.LotsStep())), 0));
      UpdateProfitLoss();
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProfitLossCalculator::UpdateProfitLoss(void) {
//---
   m_spinedit[LOSS_PIPS_EDIT].SetParameters(LossPips(), m_sym.StopsLevel(), MaxLossPips(),
                              100*m_sym.TickSize()/m_sym.Point(), 0);
   m_spinedit[PROFIT_PIPS_EDIT].SetParameters(ProfitPips(), m_sym.StopsLevel(), MaxProfitPips(),
                              100*m_sym.TickSize()/m_sym.Point(), 0);
   m_spinedit[LOSS_MONEY_EDIT].SetParameters(LossMoney(), MinLossMoney(), 
                              MaxLossMoney(), 10, 2);
   m_spinedit[PROFIT_MONEY_EDIT].SetParameters(ProfitMoney(), MinProfitMoney(), 
                              MaxProfitMoney(), 10, 2);
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CProfitLossCalculator::LossPips(void) {
   return(int(MathAbs(MathRound((m_entry_price - m_stop_price)/m_sym.Point()))));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CProfitLossCalculator::MaxLossPips(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY) 
                  ? m_spinedit[ENTRY_EDIT].MinValue() : m_spinedit[ENTRY_EDIT].MaxValue());
   return(int(MathAbs(MathRound((m_entry_price - price)/m_sym.Point()))) + m_sym.StopsLevel());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CProfitLossCalculator::ProfitPips(void) {
   return(int(MathAbs(MathRound((m_entry_price - m_profit_price)/m_sym.Point()))));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CProfitLossCalculator::MaxProfitPips(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY)
                  ? m_spinedit[ENTRY_EDIT].MaxValue() : m_spinedit[ENTRY_EDIT].MinValue());
   return(int(MathAbs(MathRound((m_entry_price - price)/m_sym.Point()))) + m_sym.StopsLevel());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::CalculateMoney(double exit_price) {
   double result = 0.0;
   
   ResetLastError();
   if ( !OrderCalcProfit((ENUM_ORDER_TYPE)m_order_type, m_sym.Name(), m_lot_value,
                         m_entry_price, exit_price, result) )
   {
      Print(__FUNCTION__, ": calculating money failed. Error #", GetLastError());
   }
//---
   return(NormalizeDouble(MathAbs(result), 2));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::LossMoney(void) {
   return(CalculateMoney(m_stop_price));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::MinLossMoney(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY) 
                  ? m_entry_price - m_sym.StopsLevel() * m_sym.Point() 
                  : m_entry_price + m_sym.StopsLevel() * m_sym.Point());

   return(CalculateMoney(price));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::MaxLossMoney(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY) 
                  ? m_spinedit[ENTRY_EDIT].MinValue() - m_sym.StopsLevel() * m_sym.Point() 
                  : m_spinedit[ENTRY_EDIT].MaxValue() + m_sym.StopsLevel() * m_sym.Point());
   
   return(CalculateMoney(price));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::ProfitMoney(void) {
   return(CalculateMoney(m_profit_price));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::MinProfitMoney(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY)
                  ? m_entry_price + m_sym.StopsLevel() * m_sym.Point() 
                  : m_entry_price - m_sym.StopsLevel() * m_sym.Point());

   return(CalculateMoney(price));  
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CProfitLossCalculator::MaxProfitMoney(void) {
   double price = ((m_order_type == (long)ORDER_TYPE_BUY)
                  ? m_spinedit[ENTRY_EDIT].MaxValue() + m_sym.StopsLevel() * m_sym.Point() 
                  : m_spinedit[ENTRY_EDIT].MinValue() - m_sym.StopsLevel() * m_sym.Point());

   return(CalculateMoney(price));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::OnChangeType(int index) {
//---
   if ( m_type_radio[index].State() ) {
      int other_index = MathAbs(index-1);
      bool other_prev_state = m_type_radio[other_index].State();
      
      m_type_radio[other_index].State(false);
      m_order_type = (index == 0) ? (long)ORDER_TYPE_BUY : (long)ORDER_TYPE_SELL;
      
      if ( other_prev_state != m_type_radio[other_index].State() ) {
         double tmp = m_stop_price;
         
         m_stop_price = m_profit_price;
         m_profit_price = tmp;
         m_line[LOSS_LINE].Price(0, m_stop_price);
         m_line[PROFIT_LINE].Price(0, m_profit_price);
         UpdateProfitLoss();
      }
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::OnChangeDoubleSpinEdit(int index) {
//---
   switch ( index ) {
   case ENTRY_EDIT:
      OnChangeEntry();
      break;
   case LOT_EDIT:
      OnChangeLot();
      break;
   case LOSS_PIPS_EDIT:
      OnChangeLossPips();
      break;
   case PROFIT_PIPS_EDIT:
      OnChangeProfitPips();
      break;
   case LOSS_MONEY_EDIT:
      OnChangeLossMoney();
      break;
   case PROFIT_MONEY_EDIT:
      OnChangeProfitMoney();
      break;
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeEntry(void) {
//---
   double new_entry = m_spinedit[ENTRY_EDIT].Value();
   double valid_max = MathMax(m_stop_price, m_profit_price) - m_sym.StopsLevel() * m_sym.Point();
   double valid_min = MathMin(m_stop_price, m_profit_price) + m_sym.StopsLevel() * m_sym.Point();
   
   if ( new_entry > valid_max || new_entry < valid_min ) {
      m_spinedit[ENTRY_EDIT].Value(m_entry_price);
      return;
   }
   
   if ( new_entry != m_entry_price ) {
      m_entry_price = new_entry;
      m_line[ENTRY_LINE].Price(0, m_entry_price);
      m_spinedit[LOSS_PIPS_EDIT].Value(LossPips());
      m_spinedit[PROFIT_PIPS_EDIT].Value(ProfitPips());
      m_spinedit[LOSS_MONEY_EDIT].Value(LossMoney());
      m_spinedit[PROFIT_MONEY_EDIT].Value(ProfitMoney());
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeLot(void) {
//---
   double new_lot = m_spinedit[1].Value();
   
   if ( new_lot != m_lot_value ) {
      m_lot_value = new_lot;
      UpdateProfitLoss();
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeLossPips(void) {
//---
   int old_value = LossPips();
   int new_value = (int)m_spinedit[LOSS_PIPS_EDIT].Value();
   
   if ( new_value != old_value ) {
      if ( m_order_type == (long)ORDER_TYPE_BUY ) {
         m_stop_price = NormalizeDouble(m_entry_price-new_value*m_sym.Point(), m_sym.Digits());
      } else {
         m_stop_price = NormalizeDouble(m_entry_price+new_value*m_sym.Point(), m_sym.Digits());
      }
      m_line[LOSS_LINE].Price(0, m_stop_price);
      m_spinedit[LOSS_MONEY_EDIT].Value(LossMoney());
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeProfitPips(void) {
//---
   int old_value = ProfitPips();
   int new_value = (int)m_spinedit[PROFIT_PIPS_EDIT].Value();
   
   if ( new_value != old_value ) {
      if ( m_order_type == (long)ORDER_TYPE_BUY ) {
         m_profit_price = NormalizeDouble(m_entry_price+new_value*m_sym.Point(), m_sym.Digits());
      } else {
         m_profit_price = NormalizeDouble(m_entry_price-new_value*m_sym.Point(), m_sym.Digits());
      }
      m_line[PROFIT_LINE].Price(0, m_profit_price);
      m_spinedit[PROFIT_MONEY_EDIT].Value(ProfitMoney());
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeLossMoney(void) {
//---
   double old_value = LossMoney();
   double new_value = m_spinedit[LOSS_MONEY_EDIT].Value();
   
   if ( new_value != old_value ) {
      int loss_pips = int(new_value/(m_lot_value*m_sym.TickValueLoss()));
      
      m_spinedit[LOSS_PIPS_EDIT].Value(loss_pips);
      if ( m_order_type == (long)ORDER_TYPE_BUY ) {
         m_stop_price = NormalizeDouble(m_entry_price-loss_pips*m_sym.Point(), m_sym.Digits());
      } else {
         m_stop_price = NormalizeDouble(m_entry_price+loss_pips*m_sym.Point(), m_sym.Digits());
      }
      m_line[LOSS_LINE].Price(0, m_stop_price);
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeProfitMoney(void) {
//---
   double old_value = ProfitMoney();
   double new_value = m_spinedit[PROFIT_MONEY_EDIT].Value();
   
   if ( new_value != old_value ) {
      int profit_pips = int(new_value/(m_lot_value*m_sym.TickValueProfit()));
      
      m_spinedit[PROFIT_PIPS_EDIT].Value(profit_pips);
      if ( m_order_type == (long)ORDER_TYPE_BUY ) {
         m_profit_price = NormalizeDouble(m_entry_price+profit_pips*m_sym.Point(), m_sym.Digits());
      } else {
         m_profit_price = NormalizeDouble(m_entry_price-profit_pips*m_sym.Point(), m_sym.Digits());
      }
      m_line[PROFIT_LINE].Price(0, m_profit_price);
   }
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProfitLossCalculator::OnEventLine(const int id, const long &lparam,
                                        const double &dparam,const string &sparam)
{
//---
   if ( id == CHARTEVENT_OBJECT_CHANGE || id == CHARTEVENT_OBJECT_DRAG ) {
      if ( sparam == line_name[ENTRY_LINE] ) {
         OnChangeEntryLine();   
      } else if ( sparam == line_name[LOSS_LINE] ) {
         OnChangeLossLine();
      } else if ( sparam == line_name[PROFIT_LINE] ) {
         OnChangeProfitLine();
      }
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeEntryLine(void) {
//---
   double new_price = NormalizeDouble(ObjectGetDouble(0, line_name[ENTRY_LINE], OBJPROP_PRICE), _Digits);
   double stops_level = m_sym.StopsLevel() * m_sym.Point();
   bool valid_buy_entry = (m_order_type == (long)ORDER_TYPE_SELL
                           && new_price < m_stop_price - stops_level 
                           && new_price > m_profit_price + stops_level);
   bool valid_sell_entry = (m_order_type == (long)ORDER_TYPE_BUY 
                           && new_price < m_profit_price - stops_level 
                           && new_price > m_stop_price + stops_level);
   
   if ( !valid_buy_entry && !valid_sell_entry ) {
      m_line[ENTRY_LINE].Price(0, m_entry_price);
      ChartRedraw();
      return;
   }
   
   m_entry_price = new_price;
   m_spinedit[ENTRY_EDIT].Value(new_price);
   m_spinedit[LOSS_PIPS_EDIT].Value(LossPips());
   m_spinedit[PROFIT_PIPS_EDIT].Value(ProfitPips());
   m_spinedit[LOSS_MONEY_EDIT].Value(LossMoney());
   m_spinedit[PROFIT_MONEY_EDIT].Value(ProfitMoney());
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeLossLine(void) {
//---
   double new_price = NormalizeDouble(ObjectGetDouble(0, line_name[LOSS_LINE], OBJPROP_PRICE), _Digits);
   double stops_level = m_sym.StopsLevel() * m_sym.Point();
   bool valid_buy_loss = (m_order_type == (long)ORDER_TYPE_BUY 
                          && new_price >= m_spinedit[ENTRY_EDIT].MinValue() - stops_level
                          && new_price <= m_entry_price - stops_level);
   bool valis_sell_loss = (m_order_type == (long)ORDER_TYPE_SELL
                          && new_price <= m_spinedit[ENTRY_EDIT].MaxValue() + stops_level
                          && new_price >= m_entry_price + stops_level);
   
   if ( !valid_buy_loss && !valis_sell_loss ) {
      m_line[LOSS_LINE].Price(0, m_stop_price);
      ChartRedraw();
      return;
   }
   
   m_stop_price = new_price;
   m_spinedit[LOSS_PIPS_EDIT].Value(LossPips());
   m_spinedit[LOSS_MONEY_EDIT].Value(LossMoney());
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProfitLossCalculator::OnChangeProfitLine(void) {
//---
   double new_price = NormalizeDouble(ObjectGetDouble(0, line_name[PROFIT_LINE], OBJPROP_PRICE), _Digits);
   double stops_level = m_sym.StopsLevel() * m_sym.Point();
   bool valid_buy_profit = (m_order_type == (long)ORDER_TYPE_BUY
                            && new_price <= m_spinedit[ENTRY_EDIT].MaxValue() + stops_level
                            && new_price >= m_entry_price + stops_level);
   bool valid_sell_profit = (m_order_type == (long)ORDER_TYPE_SELL
                            && new_price >= m_spinedit[ENTRY_EDIT].MinValue() - stops_level
                            && new_price <= m_entry_price - stops_level);
   
   if ( !valid_buy_profit && !valid_sell_profit ) {
      m_line[PROFIT_LINE].Price(0, m_profit_price);
      ChartRedraw();
      return;
   }
   
   m_profit_price = new_price;
   m_spinedit[PROFIT_PIPS_EDIT].Value(ProfitPips());
   m_spinedit[PROFIT_MONEY_EDIT].Value(ProfitMoney());
//---
}
//+------------------------------------------------------------------+
