//+------------------------------------------------------------------+
//| PROGRAMMING PATTERNS - STRATEGY                                  |
//| Incapsulate a family of interchangeable algorythms which can be  |
//| modified independently from the client.                          | 
//|                                                                  |
//| OOP CONCEPTS: Abstraction, Encapsulation, Polymorphism,          |
//| Inheritance                                                      |
//|                                                                  |
//| RULES:                                                           |
//| Encapsulate changes                                              |
//| Composition is better than inheritance.                          |
//| Engineer with interfaces, not real classes.                      |
//|                                                                  |
//| A good architecture is extendable, supportable, and reusable.    |
//| Patterns help build hq systems.                                  |
//| Patterns are proven to be good by experience.                    |
//| Patterns are generic solitions for software engineering          |
//| challenges.                                                      |
//| Choose your pattern, don't invent it.                            |
//| Most patterns are designed to manage changes of the architecture.|
//| Most patterns incapsulate variable aspects of the systems.       |
//| Developers know patterns and effectively communicate with each   |
//| other.                                                           |
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------+
//| BEHAVIOR A INTERFACE                                             |
//+------------------------------------------------------------------+
interface I_BehaviorA
  {
   void Act();
  };
//+------------------------------------------------------------------+
//| BEHAVIOR B INTERFACE                                             |
//+------------------------------------------------------------------+
interface I_BehaviorB
  {
   void Act();
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR A - OPTION A                                       |
//+------------------------------------------------------------------+
class C_BehaviorAA : public I_BehaviorA
  {
public:
   void Act() { Print(" • Doing A the a way"); }
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR A - OPTION B                                       |
//+------------------------------------------------------------------+
class C_BehaviorAB : public I_BehaviorA
  {
public:
   void Act() { Print(" • Doing A the b way"); }
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR A - OPTION C                                       |
//+------------------------------------------------------------------+
class C_BehaviorAC : public I_BehaviorA
  {
public:
//--- empty implementation
   void Act() { Print(" • Doing A is impossible"); }
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR B - OPTION A                                       |
//+------------------------------------------------------------------+
class C_BehaviorBA : public I_BehaviorB
  {
public:
   void Act() { Print(" • Doing B the a way"); }
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR B - OPTION B                                       |
//+------------------------------------------------------------------+
class C_BehaviorBB : public I_BehaviorB
  {
public:
   void Act() { Print(" • Doing B the b way"); }
  };
//+------------------------------------------------------------------+
//| REAL BEHAVIOR C - OPTION C                                       |
//+------------------------------------------------------------------+
class C_BehaviorBC : public I_BehaviorB
  {
public:
//--- empty implementation
   void Act() { Print(" • Doing B is impossible"); } 
  };
//+------------------------------------------------------------------+
//| ABSTRACT OBJECT                                                  |
//+------------------------------------------------------------------+
class A_Object
  {
public:
                    ~A_Object()
     {
      if(CheckPointer(behavior_a)==POINTER_DYNAMIC) delete behavior_a;
      if(CheckPointer(behavior_b)==POINTER_DYNAMIC) delete behavior_b;
     }
   virtual void      Name()=0;
   void ActA() { behavior_a.Act(); }
   void ActB() { behavior_b.Act(); }
   void ActC() { Print(" • Doing C the common way"); }
   void SetBehaviorA(I_BehaviorA *b)
     {
      if(CheckPointer(behavior_a)==POINTER_DYNAMIC) delete behavior_a;
      behavior_a=b;
     }
   void SetBehaviorB(I_BehaviorB *b)
     {
      if(CheckPointer(behavior_b)==POINTER_DYNAMIC) delete behavior_b;
      behavior_b=b;
     }

protected:
   I_BehaviorA      *behavior_a;
   I_BehaviorB      *behavior_b;
  };
//+------------------------------------------------------------------+
//| REAL OBJECT A                                                    |
//+------------------------------------------------------------------+
class C_ObjectA : public A_Object
  {
public:
   //--- default behavior 
                     C_ObjectA()
     {
      behavior_a=new C_BehaviorAA();
      behavior_b=new C_BehaviorBA();
     }
   void Name() { Print("Object A"); }
  };
//+------------------------------------------------------------------+
//| REAL OBJECT B                                                    |
//+------------------------------------------------------------------+
class C_ObjectB : public A_Object
  {
public:
   //--- default behavior
                     C_ObjectB()
     {
      behavior_a=new C_BehaviorAB();
      behavior_b=new C_BehaviorBA();
     }
   void Name() { Print("Object B"); }
  };
//+------------------------------------------------------------------+
//| CLIENT                                                           |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- default real object behavior
   A_Object *object_a=new C_ObjectA;
   object_a.Name();
   object_a.ActA();
   object_a.ActB();
   object_a.ActC();
//--- dynamically change behavior
   A_Object *object_b=new C_ObjectB;
   object_b.Name();
   object_b.ActA();
   object_b.ActB();
   object_b.ActC();
   object_b.SetBehaviorA(new C_BehaviorAA);
   object_b.ActA();
   object_b.SetBehaviorA(new C_BehaviorAC);
   object_b.ActA();
//---
   delete object_a;
   delete object_b;
  }
//+------------------------------------------------------------------+
//| OUTPUT                                                           |
//|                                                                  |   
//| Object A                                                         |
//|  • Doing A the a way                                             |
//|  • Doing B the a way                                             |
//|  • Doing C the common way                                        |
//| Object B                                                         |
//|  • Doing A the b way                                             |
//|  • Doing B the a way                                             |
//|  • Doing C the common way                                        |   
//|  • Doing A the a way                                             |
//|  • Doing A is impossible                                         |
//+------------------------------------------------------------------+
