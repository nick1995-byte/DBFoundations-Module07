##### *Nariman Tehrani*
##### *March 3, 2021*
##### *Foundations of Databases & SQL Programming*
##### *Assignment 07*

# SQL Functions


## Introduction:
This document explains when User-Defined Functions (UDF) are used and covers the differences between Scalar, Inline, and Multi-Statement Functions.

## When a User-Defined Function is Used:
UDFs are like regular built-in Functions in a sense that they perform an action based on the passed parameter. But unlike regular built-in functions, they are created by the user. This means they can be customized and flexible to meet each users’ needs. UDFs can be called any number of times in a Select, Where, or Case statement and can return either a single or a set of values. Figure 1 below shows an example UDF that accepts 2 parameters, adds them together, and returns the result: 

#### Figure 1: User-Defined Function Example

```
Create Function dbo.AddValues(@Value1 Float, @Value2 Float)
Returns Float 
 As
  Begin
   Return(Select @Value1 + @Value2);
  End 
go
```

## Differences Between Scalar, Inline, and Multi-Statement Functions:
Scalar Functions are UDFs that return a single value every time they are invoked. Unlike Scalar Functions, Inline Table-Valued Functions return a table instead of a single value and contain a single Select statement. In a Multi-Statement Table-Valued Function the user also specifies the structure of the table being returned. This is done by creating a Variable and then creating and structuring a Table inside that Variable. Lastly, Multi-Statement Table-Valued Functions can contain more than one Select statement. 

## Summary: 
This document explained when User-Defined Functions (UDF) are used and covered the differences between Scalar, Inline, and Multi-Statement Functions.


