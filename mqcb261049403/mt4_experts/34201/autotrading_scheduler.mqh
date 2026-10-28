#include "Defines.mqh"
#include <WinUser32.mqh>

#import "user32.dll"
  int GetAncestor(int, int);
#import

class CScheduler : public CAppDialog
{
private:
   // Buttons
   CButton			   m_BtnSwitch, m_BtnSetToAll;
   // Labels
   CLabel  		      m_LblStatus, m_LblTurnedOn, m_LblURL, m_LblAllow, m_LblExample, m_LblMonday, m_LblTuesday, m_LblWednesday, m_LblThursday, m_LblFriday, m_LblSaturday, m_LblSunday;
   //Checkbox
   CCheckBox         m_ChkClosePos;
   // Edits
   CEdit 		      m_EdtMonday, m_EdtTuesday, m_EdtWednesday, m_EdtThursday, m_EdtFriday, m_EdtSaturday, m_EdtSunday;
   // Radio Group
   CRadioGroup			m_RgpTimeType;
   
   string            m_FileName;
	bool 					IsANeedToContinueClosingTrades;
   double				m_DPIScale;
   bool              NoPanelMaximization; // Crutch variable to prevent panel maximization when Maximize() is called at the indicator's initialization.
   // Dynamic arrays to store given enabling/disabling times converted from strings.
   int               Mon_Hours[], Mon_Minutes[], Tue_Hours[], Tue_Minutes[], Wed_Hours[], Wed_Minutes[], Thu_Hours[], Thu_Minutes[], Fri_Hours[], Fri_Minutes[], Sat_Hours[], Sat_Minutes[], Sun_Hours[], Sun_Minutes[];

public:
                     CScheduler(void);
        
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1);
   virtual void      Destroy();
   virtual bool      SaveSettingsOnDisk();
   virtual bool      LoadSettingsFromDisk();
   virtual bool      DeleteSettingsFile();
   virtual bool      OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
   virtual bool      RefreshValues();
   virtual void      RefreshPanelControls();
			  void 		CheckTimer();
   virtual void		HideShowMaximize(bool max);

   // Remember the panel's location to have the same location for minimized and maximized states.
           int       remember_top, remember_left;
private:     
   virtual bool      CreateObjects();
   virtual bool      InitObjects();
   virtual void      MoveAndResize();
   virtual bool      ButtonCreate     (CButton&     Btn, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
   virtual bool      CheckBoxCreate   (CCheckBox&   Chk, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
   virtual bool      EditCreate       (CEdit&       Edt, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
   virtual bool      LabelCreate      (CLabel&      Lbl, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
   virtual bool      RadioGroupCreate (CRadioGroup& Rgp, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string &Text[]);
   virtual void      Maximize();
   virtual void      Minimize();
   virtual void      SeekAndDestroyDuplicatePanels();
   
   virtual void      Check_Status();
           void      EditDay(int &_hours[], int &_minutes[], CEdit &edt, string &sets_value);
   virtual void      Close_All_Trades();
   virtual int       Eliminate_Current_Trade(const int ticket);
           bool      CompareTime(int &_hours[], int &_minutes[], const int hour, const int minute);
           void      Toggle_AutoTrading();
  
	// Event handlers
   void OnChangeChkClosePos();
   void OnChangeRgpTimeType();
   void OnEndEditEdtMonday();
   void OnEndEditEdtTuesday();
   void OnEndEditEdtWednesday();
   void OnEndEditEdtThursday();
   void OnEndEditEdtFriday();
   void OnEndEditEdtSaturday();
   void OnEndEditEdtSunday();
   void OnClickBtnSwitch();
   void OnClickBtnSetToAll();

   // Supplementary functions:
	void RefreshConditions(const bool SettingsCheckBoxValue, const double SettingsEditValue, CCheckBox& CheckBox, CEdit& Edit, const int decimal_places);
};

// Event Map
EVENT_MAP_BEGIN(CScheduler)
   ON_EVENT(ON_CHANGE, m_ChkClosePos, OnChangeChkClosePos)
   ON_EVENT(ON_CHANGE, m_RgpTimeType, OnChangeRgpTimeType)
   ON_EVENT(ON_END_EDIT, m_EdtMonday, OnEndEditEdtMonday)
   ON_EVENT(ON_END_EDIT, m_EdtTuesday, OnEndEditEdtTuesday)
   ON_EVENT(ON_END_EDIT, m_EdtWednesday, OnEndEditEdtWednesday)
   ON_EVENT(ON_END_EDIT, m_EdtThursday, OnEndEditEdtThursday)
   ON_EVENT(ON_END_EDIT, m_EdtFriday, OnEndEditEdtFriday)
   ON_EVENT(ON_END_EDIT, m_EdtSaturday, OnEndEditEdtSaturday)
   ON_EVENT(ON_END_EDIT, m_EdtSunday, OnEndEditEdtSunday)
   ON_EVENT(ON_CLICK, m_BtnSwitch, OnClickBtnSwitch)
   ON_EVENT(ON_CLICK, m_BtnSetToAll, OnClickBtnSetToAll)
EVENT_MAP_END(CAppDialog)

//+-------------------+
//| Class constructor | 
//+-------------------+
CScheduler::CScheduler()
{
   m_FileName = "S_" + IntegerToString(ChartID()) + ".txt";
   IsANeedToContinueClosingTrades = false;
   NoPanelMaximization = false;
   remember_left = -1;
   remember_top = -1;
}

//+--------+
//| Button |
//+--------+
bool CScheduler::ButtonCreate(CButton &Btn, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
   if (!Btn.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return(false);
   if (!Add(Btn))                                                              return(false);
   if (!Btn.Text(Text))                                                        return(false);

   return(true);
}

//+----------+
//| Checkbox |
//+----------+
bool CScheduler::CheckBoxCreate(CCheckBox &Chk, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
   if (!Chk.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return(false);
   if (!Add(Chk))                                                              return(false);
   if (!Chk.Text(Text))                                                        return(false);

   return(true);
} 

//+------+
//| Edit |
//+------+
bool CScheduler::EditCreate(CEdit &Edt, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
   if (!Edt.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return(false);
   if (!Add(Edt))                                                              return(false);
   if (!Edt.Text(Text))                                                        return(false);

   return(true);
} 

//+-------+
//| Label |
//+-------+
bool CScheduler::LabelCreate(CLabel &Lbl, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
   if (!Lbl.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return(false);
   if (!Add(Lbl))                                                              return(false);
   if (!Lbl.Text(Text))                                                        return(false);

   return(true);
}

//+------------+
//| RadioGroup |
//+------------+
bool CScheduler::RadioGroupCreate(CRadioGroup &Rgp, int X1, int Y1, int X2, int Y2, string Name, const string &Text[])
{
   if (!Rgp.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return(false);
   if (!Add(Rgp))                                                              return(false);
   
   int size = ArraySize(Text);
   for (int i = 0; i < size; i++)
   {
   	if (!Rgp.AddItem(Text[i], i))															 return(false);
   }

   return(true);
}

//+-----------------------+
//| Create a panel object |
//+-----------------------+
bool CScheduler::Create(const long chart, const string name, const int subwin, const int x1, const int y1)
{
	double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
	m_DPIScale = screen_dpi / 96.0;

   int x2 = x1 + (int)MathRound(405 * m_DPIScale);
   int y2 = y1 + (int)MathRound(355 * m_DPIScale);

   if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))               return(false);
   if (!CreateObjects())                                                  		 return(false);
   return(true);
} 

void CScheduler::Destroy()
{
   m_chart.Detach();
	// Call parent destroy.
   CDialog::Destroy();
}  

bool CScheduler::CreateObjects()
{
	int row_start = (int)MathRound(10 * m_DPIScale);
	int element_height = (int)MathRound(20 * m_DPIScale);
	int v_spacing = (int)MathRound(4 * m_DPIScale);
	int h_spacing = (int)MathRound(10 * m_DPIScale);
	
	int normal_label_width = (int)MathRound(108 * m_DPIScale);
	int normal_edit_width = (int)MathRound(85 * m_DPIScale);
	int narrow_label_width = (int)MathRound(85 * m_DPIScale);
	int narrowest_edit_width = (int)MathRound(55 * m_DPIScale);
	int narrowest_label_width = (int)MathRound(30 * m_DPIScale);

	int timer_radio_width = (int)MathRound(100 * m_DPIScale);

	int first_column_start = (int)MathRound(5 * m_DPIScale);
	
	int second_column_start = first_column_start + narrowest_label_width;
	
	int third_column_start = second_column_start + (int)MathRound(250 * m_DPIScale);

	int panel_end = third_column_start + narrow_label_width;
	
	// Start
	int y = row_start;
   if (!LabelCreate(m_LblTurnedOn, first_column_start, y, first_column_start + narrow_label_width, y + element_height, "m_LblTurnedOn", "Scheduler is OFF."))             						 	 return(false);
   if (!ButtonCreate(m_BtnSwitch, first_column_start + normal_label_width, y, first_column_start + normal_label_width + normal_edit_width, y + element_height, "m_BtnSwitch", "Switch")) return(false);
	string m_RgpTimeType_Text[2] = {"Local time", "Server time"};
   if (!RadioGroupCreate(m_RgpTimeType, third_column_start - 2 * h_spacing, y, third_column_start - 2 * h_spacing + timer_radio_width, y + element_height * 2, "m_RgpTimeType", m_RgpTimeType_Text))    		 return(false);

y += element_height + 4 * v_spacing;
   if (!LabelCreate(m_LblStatus, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblStatus", "Status: "))             						 	 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblAllow, first_column_start, y, first_column_start + panel_end, y + element_height, "m_LblAllow", "Allow trading only during these times:"))             						 	 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblExample, first_column_start, y, first_column_start + panel_end, y + element_height, "m_LblExample", "Example: 12-13, 14:00-16:45, 19:55 - 21"))             						 	 return(false);
   if (!m_LblExample.Color(clrDimGray)) return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblMonday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblMonday", "Mon"))             						 	 return(false);
   if (!EditCreate(m_EdtMonday, second_column_start, y, third_column_start, y + element_height, "m_EdtMonday", ""))                                    					 		 return(false);
   if (!ButtonCreate(m_BtnSetToAll, third_column_start + h_spacing, y, third_column_start + normal_label_width, y + element_height, "m_BtnSetToAll", "Set to all empty")) return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblTuesday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblTuesday", "Tue"))             						 	 return(false);
   if (!EditCreate(m_EdtTuesday, second_column_start, y, third_column_start, y + element_height, "m_EdtTuesday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblWednesday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblWednesday", "Wed"))             						 	 return(false);
   if (!EditCreate(m_EdtWednesday, second_column_start, y, third_column_start, y + element_height, "m_EdtWednesday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblThursday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblThursday", "Thu"))             						 	 return(false);
   if (!EditCreate(m_EdtThursday, second_column_start, y, third_column_start, y + element_height, "m_EdtThursday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblFriday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblFriday", "Fri"))             						 	 return(false);
   if (!EditCreate(m_EdtFriday, second_column_start, y, third_column_start, y + element_height, "m_EdtFriday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblSaturday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblSaturday", "Sat"))             						 	 return(false);
   if (!EditCreate(m_EdtSaturday, second_column_start, y, third_column_start, y + element_height, "m_EdtSaturday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!LabelCreate(m_LblSunday, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_LblSunday", "Sun"))             						 	 return(false);
   if (!EditCreate(m_EdtSunday, second_column_start, y, third_column_start, y + element_height, "m_EdtSunday", ""))                                    					 		 return(false);

y += element_height + v_spacing;
   if (!CheckBoxCreate(m_ChkClosePos, first_column_start, y, panel_end, y + element_height, "m_ChkClosePos", "Attempt to close all trades before disabling AutoTrading."))    		 return(false);
   
y += element_height + v_spacing;

   if (!LabelCreate(m_LblURL, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblURL", "www.earnforex.com"))             						 	 return(false);
   if (!m_LblURL.FontSize(8)) return(false);
   if (!m_LblURL.Color(clrGreen)) return(false);

   SeekAndDestroyDuplicatePanels();

   return(true);
}

void CScheduler::Minimize()
{
   CAppDialog::Minimize();
   if (remember_left != -1) Move(remember_left, remember_top);
}

// Processes click on the panel's Maximize button of the panel.
void CScheduler::Maximize()
{
   if (!NoPanelMaximization) CAppDialog::Maximize();
   else if (m_minimized) CAppDialog::Minimize();

	if (remember_left != -1) Move(remember_left, remember_top);
}

// Refreshes OFF/ON and Status.
bool CScheduler::RefreshValues()
{
   Check_Status();
	
	RefreshPanelControls();
	
	return(true);
} 

// Updates all panel controls depending on the settings in sets struct.
void CScheduler::RefreshPanelControls()
{
	// Refresh time type radio group.
	m_RgpTimeType.Value(sets.TimeType);
	
	if (m_EdtMonday.Text() != sets.Monday)
	{
	   m_EdtMonday.Text(sets.Monday);
	   EditDay(Mon_Hours, Mon_Minutes, m_EdtMonday, sets.Monday);
	}
	if (m_EdtTuesday.Text() != sets.Tuesday)
	{
	   m_EdtTuesday.Text(sets.Tuesday);
	   EditDay(Tue_Hours, Tue_Minutes, m_EdtTuesday, sets.Tuesday);
	}
	if (m_EdtWednesday.Text() != sets.Wednesday)
	{
	   m_EdtWednesday.Text(sets.Wednesday);
	   EditDay(Wed_Hours, Wed_Minutes, m_EdtWednesday, sets.Wednesday);
	}
	if (m_EdtThursday.Text() != sets.Thursday)
	{
	   m_EdtThursday.Text(sets.Thursday);
	   EditDay(Thu_Hours, Thu_Minutes, m_EdtThursday, sets.Thursday);
	}
	if (m_EdtFriday.Text() != sets.Friday)
	{
	   m_EdtFriday.Text(sets.Friday);
	   EditDay(Fri_Hours, Fri_Minutes, m_EdtFriday, sets.Friday);
	}
	if (m_EdtSaturday.Text() != sets.Saturday)
	{
	   m_EdtSaturday.Text(sets.Saturday);
	   EditDay(Sat_Hours, Sat_Minutes, m_EdtSaturday, sets.Saturday);
	}
	if (m_EdtSunday.Text() != sets.Sunday)
	{
	   m_EdtSunday.Text(sets.Sunday);
	   EditDay(Sun_Hours, Sun_Minutes, m_EdtSunday, sets.Sunday);
	}
   
   m_ChkClosePos.Checked(sets.ClosePos);
   
   if (sets.TurnedOn) m_LblTurnedOn.Text("Scheduler is ON.");
   else m_LblTurnedOn.Text("Scheduler is OFF.");
}

void CScheduler::SeekAndDestroyDuplicatePanels()
{
	int ot = ObjectsTotal(ChartID());
	for (int i = ot - 1; i >= 0; i--)
	{
		string object_name = ObjectName(ChartID(), i);
		if (ObjectGetInteger(ChartID(), object_name, OBJPROP_TYPE) != OBJ_EDIT) continue;
		// Found Caption object.
		if (StringSubstr(object_name, StringLen(object_name) - 11) == "m_LblMonday")
		{
			string prefix = StringSubstr(object_name, 0, StringLen(Name()));
			// Found Caption object with prefix different than current.
			if (prefix != Name())
			{
				ObjectsDeleteAll(ChartID(), prefix);
				// Reset object counter.
				ot = ObjectsTotal(ChartID());
				i = ot;
				Print("Deleted duplicate panel objects with prefix = ", prefix, ".");
				continue;
			}
		}
	}
}

//+--------------------------------------------+
//|                                            |         
//|                   EVENTS                   |
//|                                            |
//+--------------------------------------------+

// Changes Checkbox "Attempt to close all trades".
void CScheduler::OnChangeChkClosePos()
{
   if (sets.ClosePos != m_ChkClosePos.Checked())
   {
      sets.ClosePos = m_ChkClosePos.Checked();
      SaveSettingsOnDisk();
	}
}

// Switch Scheduler ON/OFF.
void CScheduler::OnClickBtnSwitch()
{
   if (!sets.TurnedOn) sets.TurnedOn = true;
   else sets.TurnedOn = false;
   Panel.RefreshValues();
   SaveSettingsOnDisk();
}

// Set text value from Monday to all days of the week.
void CScheduler::OnClickBtnSetToAll()
{
   string monday = StringTrimRight(StringTrimLeft(m_EdtMonday.Text()));
   if (monday != "")
   {
      if (StringTrimRight(StringTrimLeft(m_EdtTuesday.Text())) == "")
      {
         m_EdtTuesday.Text(monday);
         sets.Tuesday = sets.Monday;
         EditDay(Tue_Hours, Tue_Minutes, m_EdtTuesday, sets.Tuesday);
      }
      if (StringTrimRight(StringTrimLeft(m_EdtWednesday.Text())) == "")
      {
         m_EdtWednesday.Text(monday);
         sets.Wednesday = sets.Monday;
         EditDay(Wed_Hours, Wed_Minutes, m_EdtWednesday, sets.Wednesday);
      }
      if (StringTrimRight(StringTrimLeft(m_EdtThursday.Text())) == "")
      {
         m_EdtThursday.Text(monday);
         sets.Thursday = sets.Monday;
         EditDay(Thu_Hours, Thu_Minutes, m_EdtThursday, sets.Thursday);
      }
      if (StringTrimRight(StringTrimLeft(m_EdtFriday.Text())) == "")
      {
         m_EdtFriday.Text(monday);
         sets.Friday = sets.Monday;
         EditDay(Fri_Hours, Fri_Minutes, m_EdtFriday, sets.Friday);
      }   
      if (StringTrimRight(StringTrimLeft(m_EdtSaturday.Text())) == "")
      {
         m_EdtSaturday.Text(monday);
         sets.Saturday = sets.Monday;
         EditDay(Sat_Hours, Sat_Minutes, m_EdtSaturday, sets.Saturday);
      }
      if (StringTrimRight(StringTrimLeft(m_EdtSunday.Text())) == "")
      {
         m_EdtSunday.Text(monday);
         sets.Sunday = sets.Monday;
         EditDay(Sun_Hours, Sun_Minutes, m_EdtSunday, sets.Sunday);
      }
      SaveSettingsOnDisk();
   }
}

void CScheduler::EditDay(int &_hours[], int &_minutes[], CEdit &edt, string &sets_value)
{
   string time = StringTrimRight(StringTrimLeft(edt.Text()));
	int length = StringLen(time);

   // For empty string, just clear everything.
   if (length == 0)
   {
      ArrayResize(_hours, 0);
      ArrayResize(_minutes, 0);
      sets_value = "";
      edt.Text("");
      return;
   }

   // Clean up.   
	for (int i = 0; i < length; i++)
	{
		if (((time[i] < '0') || (time[i] > '9')) && (time[i] != ' ') && (time[i] != ',') && (time[i] != ':') && (time[i] != '.') && (time[i] != '-'))
		{
			// Wrong character found.
			int replaced_characters = StringReplace(time, CharToString((uchar)time[i]), "");
			length -= replaced_characters;
			i--;
		}
	}
   
   edt.Text(time);

   // Divide.
   string times[];
   int n = StringSplit(time, ',', times);
   
   // Preliminary resizing.
   ArrayResize(_hours, n * 2); // Time ranges come in pairs of hour/minute points.
   ArrayResize(_minutes, n * 2);

   int k = 0;
   for (int i = 0; i < n; i++)
   {
      StringReplace(times[i], " ", ""); // Compactize the spacebars.
      
      string first_second_time[];
      
      int sub_n = StringSplit(times[i], '-', first_second_time);
      
      if (sub_n != 2)
      {
         Print("Error with string: ", time, " in this part: ", times[i], ".");
         continue;
      }
      for (int j = 0; j < sub_n; j++, k++)
      {
         string hours_minutes[];
         int sub_sub_n = StringSplit(first_second_time[j], ':', hours_minutes); // Split hours and minutes by colon.
         if (sub_sub_n == 1) // Colon failed.
         {
            sub_sub_n = StringSplit(first_second_time[j], '.', hours_minutes); // Split hours and minutes by period.
            if (sub_sub_n == 1) // Period failed.
            {
               // Only hours given.
               _hours[k] = (int)StringToInteger(first_second_time[j]);
               _minutes[k] = 0;
            }
            else
            {
               _hours[k] = (int)StringToInteger(hours_minutes[0]);
               _minutes[k] = (int)StringToInteger(hours_minutes[1]);
            }
         }
         else
         {
            _hours[k] = (int)StringToInteger(hours_minutes[0]);
            _minutes[k] = (int)StringToInteger(hours_minutes[1]);
         }
      }
//Print(_hours[i * 2], ":", _minutes[i * 2], "-", _hours[i * 2 + 1], ":", _minutes[i * 2 + 1]);
      // Wrong time range: 
      // If finish hours is smaller and it isn't 00:00, which could be a valid end time.
      if (((_hours[k - 2] > _hours[k - 1]) && (!((_hours[k - 1] == 0) && (_minutes[k - 1] == 0))))
       || 
      // If same hours and start minutes smaller than finish minutes.
      ((_hours[k - 2] == _hours[k - 1]) && (_minutes[k - 2] > _minutes[k - 1]))
      ||
      // If either of the hours is 24 with non-zero minutes.
      (((_hours[k - 2] == 24) && (_minutes[k - 2] != 0)) || ((_hours[k - 1] == 24) && (_minutes[k - 1] != 0))))
      {
         Print("Error with day #", i, " time range: ", _hours[k - 2], ":", _minutes[k - 2], "-", _hours[k - 1], ":", _minutes[k - 1]);
         // Remove it from the array.
         k -= 2;
      }
   }
   
   // Final resizing - without invalid ranges.
   ArrayResize(_hours, k);
   ArrayResize(_minutes, k);
   
   sets_value = time;
   
   SaveSettingsOnDisk();
}

void CScheduler::OnEndEditEdtMonday()
{
   EditDay(Mon_Hours, Mon_Minutes, m_EdtMonday, sets.Monday);
}

void CScheduler::OnEndEditEdtTuesday()
{
   EditDay(Tue_Hours, Tue_Minutes, m_EdtTuesday, sets.Tuesday);
}

void CScheduler::OnEndEditEdtWednesday()
{
   EditDay(Wed_Hours, Wed_Minutes, m_EdtWednesday, sets.Wednesday);
}

void CScheduler::OnEndEditEdtThursday()
{
   EditDay(Thu_Hours, Thu_Minutes, m_EdtThursday, sets.Thursday);
}

void CScheduler::OnEndEditEdtFriday()
{
   EditDay(Fri_Hours, Fri_Minutes, m_EdtFriday, sets.Friday);
}

void CScheduler::OnEndEditEdtSaturday()
{
   EditDay(Sat_Hours, Sat_Minutes, m_EdtSaturday, sets.Saturday);
}

void CScheduler::OnEndEditEdtSunday()
{
   EditDay(Sun_Hours, Sun_Minutes, m_EdtSunday, sets.Sunday);
}

// Saves input from the time type radio group.
void CScheduler::OnChangeRgpTimeType()
{
   if (sets.TimeType != m_RgpTimeType.Value())
   {
		sets.TimeType = (ENUM_TIME_TYPE)m_RgpTimeType.Value();
		SaveSettingsOnDisk();
	}
}

//+-----------------------+
//| Working with settings |
//|+----------------------+

// Saves settings from the panel into a file.
bool CScheduler::SaveSettingsOnDisk()
{
	int fh = FileOpen(m_FileName, FILE_TXT | FILE_WRITE);
	if (fh == INVALID_HANDLE)
	{
		Print("Failed to open file for writing: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
		return(false);
	}

	// Order does not matter.
	FileWrite(fh, "TimeType");
	FileWrite(fh, IntegerToString(sets.TimeType));
	FileWrite(fh, "ClosePos");
	FileWrite(fh, IntegerToString(sets.ClosePos));
	FileWrite(fh, "TurnedOn");
	FileWrite(fh, IntegerToString(sets.TurnedOn));
	FileWrite(fh, "Monday");
	FileWrite(fh, sets.Monday);
	FileWrite(fh, "Tuesday");
	FileWrite(fh, sets.Tuesday);
	FileWrite(fh, "Wednesday");
	FileWrite(fh, sets.Wednesday);
	FileWrite(fh, "Thursday");
	FileWrite(fh, sets.Thursday);
	FileWrite(fh, "Friday");
	FileWrite(fh, sets.Friday);
	FileWrite(fh, "Saturday");
	FileWrite(fh, sets.Saturday);
	FileWrite(fh, "Sunday");
	FileWrite(fh, sets.Sunday);
	FileClose(fh);

	return(true);
}

// Loads settings from a file to the panel.
bool CScheduler::LoadSettingsFromDisk()
{
   if (!FileIsExist(m_FileName)) return(false);
   int fh = FileOpen(m_FileName, FILE_TXT | FILE_READ);
	if (fh == INVALID_HANDLE)
	{
		Print("Failed to open file for reading: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
		return(false);
	}

	while (!FileIsEnding(fh))
	{
	   string var_name = FileReadString(fh);
	   string var_content = FileReadString(fh);
	   if (var_name == "TimeType")
	   	sets.TimeType = (ENUM_TIME_TYPE)StringToInteger(var_content);
	   else if (var_name == "ClosePos")
	   	sets.ClosePos = (bool)StringToInteger(var_content);
	   else if (var_name == "TurnedOn")
	   	sets.TurnedOn = (bool)StringToInteger(var_content);
	   else if (var_name == "Monday")
	   	sets.Monday = var_content;
	   else if (var_name == "Tuesday")
	   	sets.Tuesday = var_content;
	   else if (var_name == "Wednesday")
	   	sets.Wednesday = var_content;
	   else if (var_name == "Thursday")
	   	sets.Thursday = var_content;
	   else if (var_name == "Friday")
	   	sets.Friday = var_content;
	   else if (var_name == "Saturday")
	   	sets.Saturday = var_content;
	   else if (var_name == "Sunday")
	   	sets.Sunday = var_content;
	}

   FileClose(fh);

	return(true);
} 

// Deletes the settings file.
bool CScheduler::DeleteSettingsFile()
{
   if (!FileIsExist(m_FileName)) return(false);
   if (!FileDelete(m_FileName))
   {
   	Print("Failed to delete file: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
   	return(false);
   }
   return(true);
} 
 
void CScheduler::HideShowMaximize(bool max = true)
{
   // Remember the panel's location.
   remember_left = Left();
   remember_top = Top();

	Hide();
	Show();
	if (!max) NoPanelMaximization = true;
	else NoPanelMaximization = false;
	Maximize();
}
 
//+------------------------------------------------+
//|                                                |
//|              Operational Functions             |
//|                                                |
//+------------------------------------------------+

// Check if enabling/disabling is due.
void CScheduler::CheckTimer()
{
   if (!sets.TurnedOn) return;
   
   datetime time;
   bool enable = false; // Will turn to true if current time is within some of the given time ranges.
   
   if (sets.TimeType == Local) time = TimeLocal();
   else time = TimeCurrent();
   
   int hour = TimeHour(time);
   int minute = TimeMinute(time);
   int weekday = TimeDayOfWeek(time);

   switch(weekday)
   {
      // Monday
      case 1:
         enable = CompareTime(Mon_Hours, Mon_Minutes, hour, minute);
         break;
      // Tuesday
      case 2:
         enable = CompareTime(Tue_Hours, Tue_Minutes, hour, minute);
         break;
      // Wednesday
      case 3:
         enable = CompareTime(Wed_Hours, Wed_Minutes, hour, minute);
         break;
      // Thursday
      case 4:
         enable = CompareTime(Thu_Hours, Thu_Minutes, hour, minute);
         break;
      // Friday
      case 5:
         enable = CompareTime(Fri_Hours, Fri_Minutes, hour, minute);
         break;
      // Saturday
      case 6:
         enable = CompareTime(Sat_Hours, Sat_Minutes, hour, minute);
         break;
      // Sunday
      case 0:
         enable = CompareTime(Sun_Hours, Sun_Minutes, hour, minute);
         break;
   }
   if ((enable == false) && (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)))
   {
      if (sets.ClosePos) Close_All_Trades();
      if (IsANeedToContinueClosingTrades) Print("Not all trades have been closed! Disabling AutoTrading anyway.");
      Toggle_AutoTrading();
      return;
   }
   
   if ((enable == true) && (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))) Toggle_AutoTrading();
}

// Checks EA status.
void CScheduler::Check_Status()
{
	string s = "";
	
	if (!TerminalInfoInteger(TERMINAL_CONNECTED))
	{
		s += " No connection";
   }
	if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) && (sets.ClosePos))
	{
		if (s != "") s += ",";
		s += " No autotrading";
	} 
	else if (!MQLInfoInteger(MQL_DLLS_ALLOWED))
	{
		if (s != "") s += ",";
		s += " DLLs disabled";
	} 
   if (s == "") m_LblStatus.Text("Status: OK.");
   else m_LblStatus.Text("Status:" + s + ".");
}

bool CScheduler::CompareTime(int &_hours[], int &_minutes[], const int hour, const int minute)
{
   int total = ArraySize(_hours) / 2;
   for (int i = 0; i < total; i++)
   {
      if ((hour > _hours[i * 2]) || ((hour == _hours[i * 2]) && (minute >= _minutes[i * 2])))
      {
         // General case of being inside the time range.
         if (((hour < _hours[i * 2 + 1]) || ((hour == _hours[i * 2 + 1]) && (minute < _minutes[i * 2 + 1])))
         ||
         // 23 - 0
         ((_hours[i * 2 + 1] == 0) && (_minutes[i * 2 + 1] == 0))) return(true);
      }
   }
   return(false);
}

void CScheduler::Toggle_AutoTrading()
{
	// Toggle AutoTrading button. "2" in GetAncestor call is the "root window".
	SendMessageW(GetAncestor(WindowHandle(Symbol(), Period()), 2), WM_COMMAND, 33020, 0);
	Print("AutoTrading toggled by Scheduler.");
}

// Closes all trades.
void CScheduler::Close_All_Trades()
{
	int error = -1;
	bool AreAllTradesEliminated = true;

	if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED)))
	{
	   if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) Print("AutoTrading disabled!");
	   if (!TerminalInfoInteger(TERMINAL_CONNECTED)) Print("No connection!");
	   if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) Print("Trade not allowed!");
	   return;
	}
	
	// Closing market orders.
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS))
		{
			error = GetLastError();
			Print("AutoTrading Scheduler: OrderSelect failed " + IntegerToString(error) + ".");
			IsANeedToContinueClosingTrades = true;
		}
		else if (SymbolInfoInteger(OrderSymbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
		{
			Print("AutoTrading Scheduler: Trading disabled by broker for symbol " + OrderSymbol() + ".");
			IsANeedToContinueClosingTrades = true;
		}
		else
		{
			error = Eliminate_Current_Trade(OrderTicket());
			if (error != 0) Print("AutoTrading Scheduler: OrderClose Buy failed. Error #" + IntegerToString(error));
		}
	}
	
	// Check if all trades have been eliminated.
	if (!IsANeedToContinueClosingTrades) return;

	AreAllTradesEliminated = true;
	
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS))
		{
			error = GetLastError();
			Print("AutoTrading Scheduler: OrderSelect failed " + IntegerToString(error));
		} 
		else
		{
			AreAllTradesEliminated = false;
			break;
		}  
	}
	
	if (AreAllTradesEliminated) IsANeedToContinueClosingTrades = false;
}

// Closes an order or deletes a pending order by ticket number. Returns an error (if any).
int CScheduler::Eliminate_Current_Trade(int ticket)
{
	int error = -1;

	if (!OrderSelect(ticket, SELECT_BY_TICKET))
	{
		error = GetLastError();
		Print("AutoTrading Scheduler: OrderSelect failed " + IntegerToString(error));
		return(error);
	} 

	if (OrderType() == OP_BUY)
	{
		if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, clrNONE))
		{
			IsANeedToContinueClosingTrades = true;
			return(GetLastError());
		} 
      Print("AutoTrading Scheduler: " + OrderSymbol() + " Buy order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was closed at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_BID), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
      return(0);
   }

	if (OrderType() == OP_SELL)
	{
		if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, clrNONE))
		{
			IsANeedToContinueClosingTrades = true;
			return(GetLastError());
		}
      Print("AutoTrading Scheduler: " + OrderSymbol() + " Sell order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was closed at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_ASK), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
	   return(0);
	}

	if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT) || (OrderType() == OP_BUYSTOP) || (OrderType() == OP_SELLSTOP))
		if (!OrderDelete(OrderTicket(), clrNONE))
		{
			IsANeedToContinueClosingTrades = true;
			return(GetLastError());
		}
		else return(0);

	return(-1);
}