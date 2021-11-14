# Task 1 - Solution

## Build and Run *or whatever that is in Maude case..*

Download `maude-3.1`, cd into the unpacked directory so that you have all preludes loaded from CWD and from there run:

```
$ ./maude.linux64
./maude.linux64: /usr/lib/libtinfo.so.5: no version information available (required by ./maude.linux64)
                     \||||||||||||||||||/
                   --- Welcome to Maude ---
                     /||||||||||||||||||\
             Maude 3.1 built: Oct 12 2020 20:12:31
             Copyright 1997-2020 SRI International
                   Sun Nov 14 23:23:01 2021
Maude> load <repo_root>/task1/atm.maude 
```

## High-level design

There are 2 modules:
* `CASH` defines operations that manage banknotes of different nominal values:
    - `__` concatenate operator that allows creating `Cash` from `BankNotes`
    - `sum` that returns a sum of banknotes referred to as `Balance`
    - `_\_` Maude style set difference where we remove banknotes of lhs from RHS
        - the way this works requires `Cash` to be in descending order

* `ATM` defines operations on the ATM that provides this public interface:
    - `login(ATM, CARD_NUMBER, PIN)`
        - logs in to the ATM for given customer CARD and PIN
        - since this action, the ATM itself is in a logged-in state for given user up until he or she logouts
    - `logout(ATM)`
        - logout the currently logged in customer
    - `deposit(ATM, CASH)`
        - deposit cash to the logged-in account
    - `withdraw(ATM, REQUESTED_CASH)`
        - withdraw the cash customer requests from a logged-in ATM
        - succeeds only if the ATM has enough cash and when the logged-in customer has enough funds

The database is a list of accounts with customer card id, account balance, and pin code.
This object is accessed with getters and setters for particular fields indexed by card id.

ATM state is defined by the remote database connection, available cash, and logged-in user state.

## Examples

In these examples I use implicit op `(_).S` defined for each sort `S` to make an explicit cast to sort `S`.

Login of a customer to an ATM with a single account and 300 cash:
```
reduce in ATM : login (atm((account((1).Pin, (1234).Pin, 0)).Database, (200 100).Cash, noCustomer), (1).Card, (1234).Pin) .
```

Deposit of some cash to the customer's account:
```
reduce in ATM : deposit (atm((account(1, 1234, (0).Balance)).Database, (200 100).Cash, loggedCustomer(1)), (100 200).Cash) .
```

Withdrawal of some funds:
```
reduce in ATM : withdraw (atm((account(1, 1234, (500).Balance)).Database, (200 100).Cash, loggedCustomer(1)), (200).Cash) .
```

Logout:
```
reduce in ATM : logout(atm((account(1, 1234, (500).Balance)).Database, (200 100).Cash, loggedCustomer(1))) .
```

### Notes on error handling

ATM API does not handle errors very gracefully.
If it fails to pattern match a term then it is an error.
However, in `CASH` the `_\_` operator does some error handling in the Haskell style of `Maybe` and `Some` that may return an `Error`.
The same could be applied to ATM itself but it would be a bit harder to use.

### Missing pieces

In order for `_\_` operator to work I would have to make `__` operator in `CASH` module be decreasing ordered list of bank-notes.
I've tried to use the `ORD-LIST` from the lecture but failed to use it because natively included `LIST{X}` required `{X}` to be from theory `TRIV` while in this case, it was from `TOSET<=`.
One option that this could be sorted out would be to represent `Cash` as a quintet (tuple of 5) where `1:0:2:0:5` would be equal to `1*100 + 2*300 + 5*1000` bank-notes but this seems to be a bit neater user interface (even though internally it is a lot less efficient).
