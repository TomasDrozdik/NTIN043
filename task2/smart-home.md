# Task2 - Smart Home

## Specification Sources

[smart-home.vdmsl](./smart-home.vdmsl)

## Specification overview

Example usage is shown in *module Home* with some predefined values as well as functions for interacting with them.

At the center of my design is a station - *module Station*, that can interact with home owner - *module User*.
User can first register (*Station register_user*) using login credentials for default user.
Then she can login using newly created account.

She might want to connect a device *module Device* (*Station add_device*) and then power it on (*Station send_control*).
Devices consist of set of sensors each able to measure some value and provide an update.
Once the station is set up, users can start the station to begin polling the connected devices and display the updates on the station display.

For security reasons there is user authentication and only logged user can perform changing actions.
There is also an append only log structure (*module StationLog*) that records all actions taken on the station.

## VDMSL design choices

There is a *module Common* that covers most of the basic data types other modules use, along with sense of current time.
I've simplified some structures such as JSON to simple map of tokens to tokens, and with actual JSON implementation it should make generic enough interface for any kind of devices and their controls.

Furthermore I've simplified state of sensors into sequence of updates they will provide over time.

Additionaly core of the whole implementation is an error type *Common Error* that is simply a success `<OK>` or fail `<ERR>`.
That is the basis for error checking, I didn't want to include everything into preconditions because that would fail some computation even though sometimes error is a valid answer.
Though this might have been my misunderstanding of the VDM concepts.

## VDM issues

First of all I wasn't able to run any IDE for VDM, both overture and VDMTools ides were failing on various dependencies and later on runtime errors (e.g. Nullptr stacktrace from JVM during load of my vdmsl source).
Thus I've tried to run it using console VDM interpretter but I didn't find any reasonable manual for that and I couldn't change modules or evaluate expression from other than default module context.
I didn't make it run in the end, but I've found a syntax checker extension for VSCode so my code should be at least somewhat syntacticaly valid.
