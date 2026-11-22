//+------------------------------------------------------------------+
//|                                      GlobalVariableInspector.mq5 |
//|                                     Copyright 2026, Timon Krueger |
//|                       https://www.mql5.com/en/users/sg_mephisot |
//+------------------------------------------------------------------+
#property copyright "Timon Krueger"
#property link "https://www.mql5.com/en/users/sg_mephisot"
#property version "1.01"
#property description "Lists, exports, deletes and restores global variables of the terminal."
#property description "Filters by prefix, substring and age since last access. Delete and import"
#property description "ask for confirmation, delete writes a backup CSV first. No trading operations."
#property script_show_inputs

//--- action performed by the script
enum ENUM_GV_ACTION
  {
   GV_ACTION_LIST=0, // List in the journal
   GV_ACTION_EXPORT=1, // Export to CSV
   GV_ACTION_DELETE=2, // Delete matching variables
   GV_ACTION_IMPORT=3 // Import (restore) from CSV
  };

//--- input parameters
input ENUM_GV_ACTION   InpAction           =GV_ACTION_LIST;      // Action
input string           InpPrefix           ="";                  // Name starts with (empty = any)
input string           InpContains         ="";                  // Name contains (empty = any)
input double           InpMinAgeHours      =0.0;                 // Not accessed for at least N hours (0 = any)
input bool             InpCaseSensitive    =true;                // Case sensitive name filters
input string           InpFileName         ="";                  // CSV file in MQL5\Files (empty = automatic name)
input bool             InpBackupBeforeDelete=true;               // Write a backup CSV before deleting
input bool             InpImportOverwrite  =false;               // Import overwrites existing variables
input bool             InpAskConfirmation  =true;                // Ask before delete and import

//--- constants
#define GV_FOLDER "GlobalVariableInspector"
#define GV_SEPARATOR ';'
#define GV_TIME_MIN 946684800.0 // 2000.01.01, lower bound for "value looks like a time"
#define GV_TIME_MAX 4102444800.0 // 2100.01.01, upper bound for "value looks like a time"

//+------------------------------------------------------------------+
//| Snapshot of the global variables that pass the filters           |
//+------------------------------------------------------------------+
class CGlobalVariableList
  {
private:
   string            m_names[];
   double            m_values[];
   datetime          m_times[];
   int               m_count;
   string            m_prefix;
   string            m_contains;
   double            m_min_age_hours;
   bool              m_case_sensitive;

   bool              Matches(const string name,const datetime access_time,const datetime now) const;
   string            Normalize(const string text) const;
   void              SortByName(void);

public:
                     CGlobalVariableList(void);
   void              SetFilters(const string prefix,const string contains,const double min_age_hours,const bool case_sensitive);
   int               Collect(void);
   int               Count(void) const { return(m_count); }
   void              PrintTable(void) const;
   bool              ExportCsv(const string file_name,int &written) const;
   int               DeleteAll(void) const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGlobalVariableList::CGlobalVariableList(void) : m_count(0),
                                                 m_prefix(""),
                                                 m_contains(""),
                                                 m_min_age_hours(0.0),
                                                 m_case_sensitive(true)
  {
  }
//+------------------------------------------------------------------+
//| Store the filter settings                                        |
//+------------------------------------------------------------------+
void CGlobalVariableList::SetFilters(const string prefix,const string contains,const double min_age_hours,const bool case_sensitive)
  {
   m_case_sensitive=case_sensitive;
   m_prefix=Normalize(prefix);
   m_contains=Normalize(contains);
   m_min_age_hours=MathMax(0.0,min_age_hours);
  }
//+------------------------------------------------------------------+
//| Lower case copy of a string when the filters ignore case         |
//+------------------------------------------------------------------+
string CGlobalVariableList::Normalize(const string text) const
  {
   string result=text;
   if(!m_case_sensitive)
      StringToLower(result);
   return(result);
  }
//+------------------------------------------------------------------+
//| Check one variable against prefix, substring and age filters     |
//+------------------------------------------------------------------+
bool CGlobalVariableList::Matches(const string name,const datetime access_time,const datetime now) const
  {
   string text=Normalize(name);
//--- prefix filter
   if(m_prefix!="" && StringFind(text,m_prefix)!=0)
      return(false);
//--- substring filter
   if(m_contains!="" && StringFind(text,m_contains)<0)
      return(false);
//--- age filter, based on the last access time
   if(m_min_age_hours>0.0)
     {
      double age_hours=(double)(now-access_time)/3600.0;
      if(age_hours<m_min_age_hours)
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Read all global variables of the terminal that pass the filters  |
//+------------------------------------------------------------------+
int CGlobalVariableList::Collect(void)
  {
   m_count=0;
   int total=GlobalVariablesTotal();
   if(total<=0)
     {
      ArrayResize(m_names,0);
      ArrayResize(m_values,0);
      ArrayResize(m_times,0);
      return(0);
     }
   ArrayResize(m_names,total);
   ArrayResize(m_values,total);
   ArrayResize(m_times,total);
   datetime now=TimeLocal();
//--- first pass: names and access times only, because reading a value refreshes the access time
   string names[];
   datetime times[];
   ArrayResize(names,total);
   ArrayResize(times,total);
   for(int i=0; i<total; i++)
     {
      names[i]=GlobalVariableName(i);
      times[i]=GlobalVariableTime(names[i]);
     }
//--- second pass: keep the matching variables and read their values
   for(int i=0; i<total; i++)
     {
      if(names[i]=="")
         continue;
      if(!Matches(names[i],times[i],now))
         continue;
      double value=0.0;
      if(!GlobalVariableGet(names[i],value))
         continue;
      m_names[m_count]=names[i];
      m_values[m_count]=value;
      m_times[m_count]=times[i];
      m_count++;
     }
   ArrayResize(m_names,m_count);
   ArrayResize(m_values,m_count);
   ArrayResize(m_times,m_count);
   SortByName();
   return(m_count);
  }
//+------------------------------------------------------------------+
//| Insertion sort by name, the list is small                        |
//+------------------------------------------------------------------+
void CGlobalVariableList::SortByName(void)
  {
   for(int i=1; i<m_count; i++)
     {
      string name=m_names[i];
      double value=m_values[i];
      datetime time=m_times[i];
      int j=i-1;
      while(j>=0 && StringCompare(m_names[j],name,false)>0)
        {
         m_names[j+1]=m_names[j];
         m_values[j+1]=m_values[j];
         m_times[j+1]=m_times[j];
         j--;
        }
      m_names[j+1]=name;
      m_values[j+1]=value;
      m_times[j+1]=time;
     }
  }
//+------------------------------------------------------------------+
//| Text form of a value, plus a date when it looks like a timestamp |
//+------------------------------------------------------------------+
string ValueToText(const double value)
  {
   return(StringFormat("%.15g",value));
  }
//+------------------------------------------------------------------+
//| Date form of a value that holds a whole number of seconds        |
//+------------------------------------------------------------------+
string ValueAsTime(const double value)
  {
   if(value<GV_TIME_MIN || value>GV_TIME_MAX)
      return("");
   if(MathAbs(value-MathRound(value))>0.0)
      return("");
   return(TimeToString((datetime)(long)value,TIME_DATE|TIME_SECONDS));
  }
//+------------------------------------------------------------------+
//| Age since the last access as a short text                        |
//+------------------------------------------------------------------+
string AgeToText(const datetime access_time,const datetime now)
  {
   long seconds=(long)(now-access_time);
   if(seconds<0)
      seconds=0;
   if(seconds<3600)
      return(StringFormat("%dm",(int)(seconds/60)));
   if(seconds<86400)
      return(StringFormat("%.1fh",seconds/3600.0));
   return(StringFormat("%.1fd",seconds/86400.0));
  }
//+------------------------------------------------------------------+
//| Print the snapshot as a table into the Experts journal           |
//+------------------------------------------------------------------+
void CGlobalVariableList::PrintTable(void) const
  {
   datetime now=TimeLocal();
   PrintFormat("%-40s %22s  %-19s  %8s  %s","Name","Value","Last access","Age","Value as time");
   for(int i=0; i<m_count; i++)
     {
      PrintFormat("%-40s %22s  %-19s  %8s  %s",
                  m_names[i],
                  ValueToText(m_values[i]),
                  TimeToString(m_times[i],TIME_DATE|TIME_SECONDS),
                  AgeToText(m_times[i],now),
                  ValueAsTime(m_values[i]));
     }
  }
//+------------------------------------------------------------------+
//| Write the snapshot to a CSV file in MQL5\Files                   |
//+------------------------------------------------------------------+
bool CGlobalVariableList::ExportCsv(const string file_name,int &written) const
  {
   written=0;
   int handle=FileOpen(file_name,FILE_WRITE|FILE_CSV|FILE_ANSI,GV_SEPARATOR);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Cannot create %s, error %d",file_name,GetLastError());
      return(false);
     }
//--- header, the import reads the first two columns
   FileWrite(handle,"name","value","last_access","value_as_time");
   for(int i=0; i<m_count; i++)
     {
      //--- a name that contains the separator cannot be restored from this file
      if(StringFind(m_names[i],CharToString((uchar)GV_SEPARATOR))>=0)
        {
         PrintFormat("Skipped %s: the name contains the CSV separator",m_names[i]);
         continue;
        }
      FileWrite(handle,m_names[i],ValueToText(m_values[i]),
                TimeToString(m_times[i],TIME_DATE|TIME_SECONDS),ValueAsTime(m_values[i]));
      written++;
     }
   FileClose(handle);
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete every variable of the snapshot                            |
//+------------------------------------------------------------------+
int CGlobalVariableList::DeleteAll(void) const
  {
   int deleted=0;
   for(int i=0; i<m_count; i++)
     {
      if(GlobalVariableDel(m_names[i]))
         deleted++;
      else
         PrintFormat("Cannot delete %s, error %d",m_names[i],GetLastError());
     }
   GlobalVariablesFlush();
   return(deleted);
  }
//+------------------------------------------------------------------+
//| Automatic file name with the local time                          |
//+------------------------------------------------------------------+
string AutoFileName(const string tag)
  {
   MqlDateTime t;
   TimeToStruct(TimeLocal(),t);
   return(StringFormat("%s\\gv_%s_%04d%02d%02d_%02d%02d%02d.csv",
                       GV_FOLDER,tag,t.year,t.mon,t.day,t.hour,t.min,t.sec));
  }
//+------------------------------------------------------------------+
//| File name from the input or an automatic one                     |
//+------------------------------------------------------------------+
string TargetFileName(const string tag)
  {
   string name=InpFileName;
   StringTrimLeft(name);
   StringTrimRight(name);
   if(name=="")
      return(AutoFileName(tag));
   return(name);
  }
//+------------------------------------------------------------------+
//| Yes/No dialog, always yes when confirmation is switched off      |
//+------------------------------------------------------------------+
bool Confirm(const string text)
  {
   if(!InpAskConfirmation)
      return(true);
   if(MQLInfoInteger(MQL_TESTER))
      return(false);
   int answer=MessageBox(text,"Global Variable Inspector",MB_YESNO|MB_ICONQUESTION);
//--- a dialog ended by closing the terminal or the chart never counts as yes
   if(IsStopped())
      return(false);
   return(answer==IDYES);
  }
//+------------------------------------------------------------------+
//| Short text that describes the active filters                     |
//+------------------------------------------------------------------+
string FilterText(void)
  {
   string text="";
   if(InpPrefix!="")
      text+=StringFormat(" prefix \"%s\"",InpPrefix);
   if(InpContains!="")
      text+=StringFormat(" contains \"%s\"",InpContains);
   if(InpMinAgeHours>0.0)
      text+=StringFormat(" age >= %.1f h",InpMinAgeHours);
   if(text=="")
      text=" none";
   return(text);
  }
//+------------------------------------------------------------------+
//| Restore variables from a CSV file written by the export          |
//+------------------------------------------------------------------+
void ImportCsv(void)
  {
   string file_name=InpFileName;
   StringTrimLeft(file_name);
   StringTrimRight(file_name);
   if(file_name=="")
     {
      Print("Import needs a file name, for example GlobalVariableInspector\\gv_export_20260927_101500.csv");
      return;
     }
   int handle=FileOpen(file_name,FILE_READ|FILE_CSV|FILE_ANSI,GV_SEPARATOR);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Cannot open %s, error %d",file_name,GetLastError());
      return;
     }
//--- first pass: read all rows so the dialog can show their number
   string names[];
   double values[];
   int rows=0;
   bool header=true;
   while(!FileIsEnding(handle))
     {
      string name=FileReadString(handle);
      string value_text="";
      if(!FileIsLineEnding(handle) && !FileIsEnding(handle))
         value_text=FileReadString(handle);
      //--- skip the remaining columns of the row
      while(!FileIsLineEnding(handle) && !FileIsEnding(handle))
         FileReadString(handle);
      if(header)
        {
         header=false;
         if(name=="name")
            continue;
        }
      StringTrimLeft(name);
      StringTrimRight(name);
      StringTrimLeft(value_text);
      StringTrimRight(value_text);
      if(name=="" || value_text=="")
         continue;
      if(StringLen(name)>63)
        {
         PrintFormat("Skipped %s: names are limited to 63 characters",name);
         continue;
        }
      ArrayResize(names,rows+1,64);
      ArrayResize(values,rows+1,64);
      names[rows]=name;
      values[rows]=StringToDouble(value_text);
      rows++;
     }
   FileClose(handle);
   if(rows==0)
     {
      PrintFormat("%s contains no rows to import",file_name);
      return;
     }
//--- confirmation before anything is written
   string question=StringFormat("Import %d global variables from %s?\n%s",rows,file_name,
                                InpImportOverwrite ? "Existing variables will be overwritten." : "Existing variables are kept.");
   if(!Confirm(question))
     {
      Print("Import cancelled, nothing changed");
      return;
     }
//--- second pass: write the variables
   int created=0,overwritten=0,kept=0,failed=0;
   for(int i=0; i<rows; i++)
     {
      bool exists=GlobalVariableCheck(names[i]);
      if(exists && !InpImportOverwrite)
        {
         kept++;
         continue;
        }
      if(GlobalVariableSet(names[i],values[i])==0)
        {
         PrintFormat("Cannot set %s, error %d",names[i],GetLastError());
         failed++;
         continue;
        }
      if(exists)
         overwritten++;
      else
         created++;
     }
   GlobalVariablesFlush();
   PrintFormat("Import from %s: %d created, %d overwritten, %d kept, %d failed",
               file_name,created,overwritten,kept,failed);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- import does not need a snapshot
   if(InpAction==GV_ACTION_IMPORT)
     {
      ImportCsv();
      return;
     }
//--- snapshot of the matching variables
   CGlobalVariableList list;
   list.SetFilters(InpPrefix,InpContains,InpMinAgeHours,InpCaseSensitive);
   int found=list.Collect();
   PrintFormat("Global variables: %d in the terminal, %d match the filters (%s )",
               GlobalVariablesTotal(),found,FilterText());
   if(found==0)
      return;
//--- list
   if(InpAction==GV_ACTION_LIST)
     {
      list.PrintTable();
      return;
     }
//--- export
   if(InpAction==GV_ACTION_EXPORT)
     {
      string file_name=TargetFileName("export");
      int written=0;
      if(list.ExportCsv(file_name,written))
         PrintFormat("Exported %d variables to MQL5\\Files\\%s",written,file_name);
      return;
     }
//--- delete: a delete without any filter needs an explicit answer
   list.PrintTable();
   string question=StringFormat("Delete %d global variables (filters:%s )?",found,FilterText());
   if(InpPrefix=="" && InpContains=="" && InpMinAgeHours<=0.0)
      question+="\nNo filter is set: this deletes ALL global variables of the terminal.";
   question+="\nExpert Advisors that use these variables lose their stored state.";
   if(!Confirm(question))
     {
      Print("Delete cancelled, nothing changed");
      return;
     }
//--- backup first, stop when the backup cannot be written
   if(InpBackupBeforeDelete)
     {
      string backup=AutoFileName("backup");
      int written=0;
      if(!list.ExportCsv(backup,written))
        {
         Print("Backup failed, delete aborted");
         return;
        }
      PrintFormat("Backup of %d variables written to MQL5\\Files\\%s",written,backup);
     }
   int deleted=list.DeleteAll();
   PrintFormat("Deleted %d of %d variables",deleted,found);
  }
//+------------------------------------------------------------------+
