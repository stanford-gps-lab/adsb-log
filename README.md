# ADS-B Log #

This is a MATLAB toolbox for handling ADS-B log data in a JSON format provided by the MONA project.

To get the code on your computer, follow the steps presented in the [Gettting Started](#getting-started) section based on how you would like to download the code to your computer.

To get up and running and using the toolbox, check out the [Using the Toolbox](#using-the-toolbox) section that walks through importing a JSON log file, sorting through the data, and creating a KML file containing the data from several of the flights.


## Getting Started ##

TODO: add how to download the toolbox, or how to clone the code and add it to the MATLAB path.

### Toolbox ###

NOTE: these instructions coming, once I give it a try.


### Clone of Code ###

If you clone the code to your computer (with `git clone https://github.com/adrnp/adsb-log.git`) you will need to make sure you add the `adsblog` directory to your MATLAB path.

Follow along with MATLAB's [guide to adding a directory to the path](https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) and make sure you add the `adsblog` directory within this repository to the MATLAB path.  **Note:** You need only add the one directory (folder) to the path.


## Using the Toolbox ##

This section walks through a simple example of a task that might be done using this toolbox, from importing the JSON file to selecting a subset of aircraft information and creating a KML file containing the flight information.

### Importing JSON File ###

Given a JSON file that contains the log information for a full day (e.g. `FA_Sightings.190414.airport_ids.json`), the first step is to import all the data contained within that log into MATLAB.

To import the data into a list of [`Aircraft`](#aircraft) types containing all the log data, the command is:

```matlab
aircraftData = adsblog.importJSONLog('FA_Sightings.190414.airport_ids.json');
```

**Note:** the input to this import function is the full path to the log file.

Now the variable `aircraftData` contains a list of `Aircraft` types that contains all the log data, which includes every sighting for each of the aircraft.


### Sorting Through Aircraft ###

The log files typically contain the information on aircraft for an entire day and once imported into MATLAB it may be unwiedly working with the full list of imported aircraft and associated data.  There are several helper functions in place to be able to find a desired subset of aircraft within the list:

 - `acList.getAircraftByICAO(icao)` - this function goes through the list of aircraft in `acList` and returns the specific aircraft of interest as specified by the ICAO hex ID.
 - `acList.getAircraftByLocation(lat, lon)` - this function goes through the list of aircraft in `acList` and returns the subset of aircraft that meet a condition to consider them tied to a given (lat, lon) coordinate.

These functions act on a list of `Aircraft` type, such as the list created on import.  Continuing with the example from above, if we wanted to find a subset of aircraft that landed at Hayward Airport (lat = `37.659`, lon = `-122.122`), the command looks like:

```matlab
ac = aircraftData.getAircraftByLocation(37.659, -122.122);
```


### Creating a KML ###

Now we have a subset of the aircraft list contained in a new variable `ac`.  This subset contains only the aircraft that passed close enough to the (lat, lon) point that defined Hayward Airport.  One thing we might be interested in doing in creating a KML file that contains the flight paths given by all the sightings for each plane.

To do this task, we can use the `createKML()` function:

```matlab
ac.createKML('kml-file-name');
```

If no parameter is passed, then the function will use a default filename.

**Note:** the filename does not contain an extension.  This is because the function `createKML()` create 2 different types of KML files (one with a time slider, one without) and appends an identifier to the filename for the 2 different file types and then adds the `.kml` extension.

## Details ##

This toolbox breaks down the JSON log data into 3 key classes that serve as containers for the data, and have some helper functions:

 - [Aircraft](#aircraft)
 - [Flight Log](#flight-log)
 - [Log Message](#log-message)

At a very high level, each ADS-B sighting is converted to a `LogMessage`, a collection of continuous sightings, or flight segment, is contained in `FlightLog` and finally all of this is tied to a specific aircraft and is all contained in an `Aircraft`.

**Note:** For full documentation of each of the classes, the functions available to them, etc. use MATLAB's `help` function.  These descriptions below are merely to serve as a starting point to help understand the overall structure as to how the log data is broken down and imported into MATLAB for manipulation.

### Aircraft ###

The `Aircraft` class is a container for each of the different aircraft that are contained within the JSON log data.  An `Aircraft` contains a set of metadata about the aircraft itself (e.g. type, ICAO number, tail number, etc) and a list of `FlightLog` data types, where each `FlightLog` is what the JSON structure calls a flight segment.

To help sort through a list of aircrafts and find different subsets, there are several helper functions provided in the class.  For specific details, use `help adsblog.Aircraft` to pull up the detailed documentation.

### Flight Log ###

The `FlightLog` class is another container to encapsulate the metadata for a given flight segment and contains a list of `LogMessage` data types that each contain a specific ADS-B sighting.  The `FlightLog` metadata contains information such as the segment number, the number of sighting in the segment, duration of the segment, etc.

For the log, a flight segment is considered to be a "continuous" collection of ADS-B sightings for a given aircraft.  Some aircraft may have a single flight be considered multiple segments if, for example, the flight took off from the Bay Area to Lake Tahoe and back due to the fact that in doing so the aircraft will go out of range of the feeder antennas located in the Bay Area and the flight will therefore be broke into 2 continuous segments.

Each segment does contain `origin` and `destination` data that is a post processed attempt at specifying the mjaor airport in the Bay Area from which it either left or is arriving.  This data is not the most trustworthy so use it cautiously.

### Log Message ###

The `LogMessage` class is the final container used to represent the JSON log data.  This class encapsulates the data for each of the ADS-B sightings.  Note that some of the sightings are interpolated sightings and flagged accordingly in the log message for that sighting.