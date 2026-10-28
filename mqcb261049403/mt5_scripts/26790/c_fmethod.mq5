/*********************************************************************
                                                           MQL5 Script
                                                Copyright 2019, dmipec
                                                      792112@gmail.com

  Factory Method (Virtual Constructor) Programming Pattern

  This pattern was published in the "Design Patterns: Elements of
  Reusable Object-Oriented Software", 1st Edition, by Erich Gamma
  (Author), Richard Helm (Author), Ralph Johnson (Author), John
  Vlissides (Author), Grady Booch (Foreword). These authors are
  collectively known as Gang of Four (GoF).

  Structure (diagram)

  Intent
  Define an interface for creating an object, but let subclasses
  decide which class to instantiate. Factory Method lets a class defer
  instantiation to subclasses.

  Applicability
  - a class can't anticipate the class of objects it must create.
  - a class wants its subclasses to specify the objects it creates.
  - classes delegate responsibility to one of several helper
    subclasses, and you want to localize the knowledge of which helper
    subclass is the delegate.

  Participants
    Product
    - defines the interface of objects the factory method creates.
    Concrete Product
    - implements the Product interface.
    Creator
    - declares the factory method, which returns an object of type
      Product.
      Creator may also define a default implementation of the factory
      method that returns a default ConcreteProduct object.
    - may call the factory method to create a Product object.
    Concrete Creator
    - overrides the factory method to return an instance of a
      ConcreteProduct.

  Collaborations
  Creator relies on its subclasses to define the factory method so
  that it returns an instance of the appropriate ConcreteProduct.

  Consequences
  Factory methods eliminate the need to bind application-specific
  classes into your code. The code only deals with the Product
  interface; therefore it can work with any user-defined
  ConcreteProduct classes.
    A potential disadvantage of factory methods is that clients might
  have to subclass the Creator class just to create a particular
  ConcreteProduct object. Subclassing is fine when the client has to
  subclass the Creator class anyway, but otherwise the client now must
  deal with another point of evolution.
  Here are two additional consequences of the Factory Method pattern:
  1. Provides hooks for subclasses.
    Creating objects inside a class with a factory method is always
    more flexible than creating an object directly. Factory Method
    gives subclasses a hook for providing an extended version of an
    object.
      A class could define a factory method that creates a default
    object. A subclass can define an application-specific class by
    overriding this factory method. In this case the factory method is
    not abstract but provides a reasonable default implementation.
  2. Connects parallel class hierarchies.
    In the examples we've considered so far, the factory method is
    only called by Creators. But this doesn't have to be the case;
    clients can find factory methods useful, especially in the case
    of parallel class hierarchies.
      Parallel class hierarchies result when a class delegates some of
    its responsibilities to a separate class. Consider objects that
    can be manipulated interactively. Implementing such interactions
    isn't always easy. It often requires storing and updating
    information that records the state of the manipulation at a
    given time. This state is needed only during manipulation;
    therefore it needn't be kept in the object. Moreover, different
    objects behave differently when the user manipulates them.
      With these constraints, it's better to use a separate Manipulator
    object that implements the interaction and keeps track of any
    manipulation-specific state that's needed. Different objects will
    use different Manipulator subclasses to handle particular
    interactions. The resulting Manipulator class hierarchy
    parallels (at least partially) the class hierarchy.
      The class provides a CreateManipulator factory method that lets
    clients create a objects's corresponding Manipulator. Object
    subclasses override this method to return an instance of the
    Manipulator subclass that's right for them. Alternatively, the
    class may implement CreateManipulator to return a default
    Manipulator instance, and object subclasses may simply inherit that
    default. The classes that do so need no corresponding Manipulator
    subclass—hence the hierarchies are only partially parallel.
    Notice how the factory method defines the connection between the
    two class hierarchies. It localizes knowledge of which classes
    belong together.

  Implementation
  Consider the following issues when applying the Factory Method
  pattern:
  1. Two major varieties.
    The two main variations of the Factory Method pattern are
    (1) the case when the Creator class is an abstract class and
    does not provide an implementation for the factory method it
    declares, and (2) the case when the Creator is a concrete class
    and provides a default implementation for the factory method.
    It's also possible to have an abstract class that defines a
    default implementation, but this is less common.
      The first case requires subclasses to define an implementation,
    because there's no reasonable default. It gets around the
    dilemma of having to instantiate unforeseeable classes. In the
    second case, the concrete Creator uses the factory method
    primarily for flexibility. It's following a rule that says,
    "Create objects in a separate operation so that subclasses can
    override the way they're created." This rule ensures that
    designers of subclasses can change the class of objects
    their parent class instantiates if necessary.
  2. Parameterized factory methods.
    Another variation on the pattern lets the factory method create
    multiple kinds of products. The factory method takes a parameter
    that identifies the kind of object to create. All objects the
    factory method creates will share the Product interface.

  Code output
    Received Product #2097152 from Creator 1 factory method
    Running Creator 1 operation with Product #3145728
    Received Default product #5242880 from Creator 2 factory method
    Running Creator 2 operation with Default product #6291456         */
    
/*********************************************************************
  Product                                                             */
interface IProduct {
  string             Id();
};
/*********************************************************************
  Concrete Product 1                                                  */
class CProduct1: public IProduct {
public:
  string             Id();
};
/*********************************************************************
  Concrete Product 2                                                  */
class CProduct2: public IProduct {
public:
  string             Id();
};
/*********************************************************************
  Creator (abstract)                                                            
  Non-Parameterized factory method with default implementation        */
class ACreator {
public:
  virtual string     Id() = 0;
  virtual IProduct   *FactoryMethod();
  void               Operation(); 
};
/*********************************************************************
  Concrete Creator 1                                                  */
class CCreator1: public ACreator {
public:
  string             Id();
  IProduct           *FactoryMethod();
};
/*********************************************************************
  Concrete Creator 2                                                  */
class CCreator2: public ACreator {
public:
  string             Id();
};

/*********************************************************************
  This Client function does not belong to the pattern.
  For demonstration purpose.                                          */
void Client(ACreator*creator)
{
  IProduct *product = creator.FactoryMethod();
  printf("Received %s #%d from %s factory method", product.Id(), product, creator.Id());
  creator.Operation();
  delete product;
  delete creator;
}
/*********************************************************************
  Script                                                              */
void OnStart()
{
//--- creator with factory method override
  Client(new CCreator1);
//--- creator without override (default factory method)
  Client(new CCreator2);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Default Product ID                                                  */
string CProduct1::Id(void)
{
  return "Default product";
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Product ID                                                          */
string CProduct2::Id(void)
{
  return "Product";
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Default Factory Method                                              */
IProduct *ACreator::FactoryMethod()
{
  return new CProduct1;
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  An Operation                                                        */
void ACreator::Operation()
{
  IProduct *product = FactoryMethod();
  printf("Running %s operation with %s #%d", Id(), product.Id(), product);
  delete product;
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Creator 1 Factory Method override                                   */
IProduct *CCreator1::FactoryMethod()
{
  return new CProduct2;
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Creator 1 ID                                                        */
string CCreator1::Id(void)
{
  return "Creator 1";
}
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Creeator 2 ID                                                       */
string CCreator2::Id(void)
{
  return "Creator 2";
}
/*********************************************************************
    The code was formatted with Stroustrup C++ style (MetaEditor >
       Tools > Options > Styler). Navigate with Alt-G/M/Arrows        */
