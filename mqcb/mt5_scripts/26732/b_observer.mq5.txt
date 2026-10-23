//+------------------------------------------------------------------+
//| PROGRAMMING PATTERNS - OBSERVER                                  |
//| When the subject changes, it notifies and updates its observers, |
//|   who know nothing about each other (one-to-many weak relation)  |
//|                                                                  |
//| RULE                                                             |   
//|  • Use weak connection between communicating objects.            |   
//|                                                                  |
//| CONCEPTS:                                                        |
//|  • Subjects update observers through interface.                  |   
//|  • Subjects knows nothing about its observers.                   |
//|  • New data can be broadcast by the subject, or requested by the |
//|      observers (better).                                         |
//|  • Order of notification is not guaranteed.                      |   
//+------------------------------------------------------------------+

//--- import generic object array from the standard MQL library
#include <Generic\ArrayList.mqh>
//+------------------------------------------------------------------+
//| OBSERVER INTERFACE                                               |
//+------------------------------------------------------------------+
interface I_Observer
  {
//--- broadcast any object/applicable variable(s) to the observers
   void Update(int var);
  };
//+------------------------------------------------------------------+
//| ADDITIONAL INTERFACE                                             |
//| Multiple inheritance is not supported by MQL, so I had to extend |
//|   the observer interface to roughly emulate inheritance from two |
//|   independent interfaces.                                        |
//| This interface is optional to the pattern.                       |
//+------------------------------------------------------------------+
interface I_ObserverExtended : public I_Observer
  {
//--- additional useful functionality for observers
   void Process();
  };
//+------------------------------------------------------------------+
//| SUBJECT INTERFACE                                                |
//+------------------------------------------------------------------+
interface I_Subject
  {
   void RegisterObserver(I_Observer *o);
   void RemoveObserver(I_Observer *o);
   void NotifyObservers();
  };
//+------------------------------------------------------------------+
//| REAL SUBJECT                                                     |
//+------------------------------------------------------------------+
class C_Subject : public I_Subject
  {
public:
                    ~C_Subject()
     {
      Clear(m_observers);
      Clear(m_bin);
     }
   //---
   void RegisterObserver(I_Observer *o) { m_observers.Add(o); }
   void RemoveObserver(I_Observer *o)
     {
      m_observers.Remove(o);
      m_bin.Add(o);
     }
   void NotifyObservers()
     {
      I_Observer *observer;
      int total=m_observers.Count();
      for(int i=0; i<total; i++)
        {
         m_observers.TryGetValue(i,observer);
         observer.Update(m_var);
        }
     }
   void Broadcast()
     {
      Print("Broadcasting new data");
      NotifyObservers();
     }
   //--- obtain data externally and submit to observers
   void Data(int var)
     {
      m_var=var;
      Broadcast();
     }

protected:
   void Clear(CArrayList<I_Observer*>&list)
     {
      I_Observer *observer;
      int total=list.Count();
      for(int i=0; i<total; i++)
        {
         list.TryGetValue(i,observer);
         if(CheckPointer(observer)==POINTER_DYNAMIC) delete observer;
        }
      list.Clear();
     }

   //---
   //data/object(s) to be communicated to the subscribers
   int               m_var;
   //list of observers 
   CArrayList<I_Observer*>m_observers;
   //trash
   CArrayList<I_Observer*>m_bin;
  };
//+------------------------------------------------------------------+
//| REAL OBSERVER A                                                  |
//+------------------------------------------------------------------+
class C_ObserverA : public I_ObserverExtended
  {
public:
                     C_ObserverA(I_Subject *subject)
     {
      m_subject=subject;
      m_subject.RegisterObserver(GetPointer(this));
     }
   void Update(int var)
     {
      m_var=var;
      Process();
     }
   void Process() { PrintFormat(" • Observer A - value: %g",m_var); }

protected:
   I_Subject        *m_subject;
   //--- data needed from the subject
   int               m_var;
  };
//+------------------------------------------------------------------+
//| REAL OBSERVER B                                                  |
//+------------------------------------------------------------------+
class C_ObserverB : public I_ObserverExtended
  {
public:
                     C_ObserverB(I_Subject *subject)
     {
      m_subject=subject;
      m_subject.RegisterObserver(GetPointer(this));
     }
   void Update(int var)
     {
      m_var=var;
      Process();
     }
   void Process() { PrintFormat(" • Observer B - square: %g",m_var*m_var); }

protected:
   I_Subject        *m_subject;
   //--- data needed from the subject
   int               m_var;
  };
//+------------------------------------------------------------------+
//| CLIENT                                                           |
//+------------------------------------------------------------------+
void OnStart()
  {
   C_Subject subject;
//---
   I_Observer *observer_a=new C_ObserverA(GetPointer(subject));
   subject.Data(2);
   I_Observer *observer_b=new C_ObserverB(GetPointer(subject));
   subject.Data(3);
//--- dynamically connect/disconnect observers
   subject.RemoveObserver(observer_a);
   subject.Data(5);
   subject.RemoveObserver(observer_b);
   subject.Data(7);
   subject.RegisterObserver(observer_a);
   subject.Data(11);
   subject.RegisterObserver(observer_b);
   subject.Data(13);
  }
//+------------------------------------------------------------------+
//| Broadcasting new data                                            |
//|  • Observer A - value: 2                                         |
//| Broadcasting new data                                            |
//|  • Observer A - value: 3                                         |
//|  • Observer B - square: 9                                        |
//| Broadcasting new data                                            |
//|  • Observer B - square: 25                                       |
//| Broadcasting new data                                            |
//| Broadcasting new data                                            |
//|  • Observer A - value: 11                                        |
//| Broadcasting new data                                            |
//|  • Observer A - value: 13                                        |
//|  • Observer B - square: 169                                      |
//+------------------------------------------------------------------+
