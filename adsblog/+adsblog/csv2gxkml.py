""" Convert the position CSV to a KML file

This uses GxTracks to be able to have time information tagged to all
the tracks that are shown
"""

import os
import glob
import csv
import sys
import datetime
import pytz
import simplekml as skml

def generateKMLForFlight(kmldoc, fname, goodstyle, badstyle):



    # get the icao code from the filename
    icao = fname[9:-4]
    fol = kmldoc.newfolder(name=icao)
    currfolder = fol

    # get timezone info
    localtz = pytz.timezone('America/Los_Angeles')

    #
    # Flight GPS Data
    #
    gpsdata_file = fname

    # create the when array (time info) and coord array
    allWhen = []   # container for all of the segments
    allCoord = []  # container for all the segments
    allInd = 0     # the index of where at in the all arrays
    with open(gpsdata_file, 'rb') as f:
        reader = csv.reader(f, delimiter=',')

        # need to indexing variables
        segmentInd = -1
        estimated = 0
        createNewSegment = False

        when = []   # list for a single segment
        coord = []  # list for a single segment
        for row in reader:
            # get the elements of the row
            seg = int(row[0])
            est = int(row[1])
            dt = datetime.datetime.fromtimestamp(float(row[2]))
            dtAware = localtz.localize(dt)
            tstring = dtAware.isoformat()
            lat = float(row[3])
            lon = float(row[4])
            alt = float(row[5])/3.281  # convert from ft to meters

            # going to create a new segment if going to an estimated position
            if est == 1:
                if estimated == 0:
                    createNewSegment = True

            else:  # est == 0
                # if we were previously in estimated points and now
                # are back to normal, will want to create a new segment
                if estimated == 1:
                    createNewSegment = True

                    # want to add this point to the estimated segment
                    # since the estimated segments ends with this point
                    when.append(tstring)
                    coord.append((lon, lat, alt))

                    # also want to add the last point from the previous segment
                    lastWhen = allWhen[allInd-1]
                    lastCoord = allCoord[allInd-1]
                    when.insert(0, lastWhen[-1])
                    coord.insert(0, lastCoord[-1])

            if segmentInd == -1:
                # set the segment information (this is the first point)
                segmentInd = seg
                currfolder = fol.newfolder(name='{0}'.format(segmentInd))

            elif segmentInd != seg:
                # if we have a new segment index, create a new line
                createNewSegment = True

            # create the path for the last segment
            if createNewSegment:
                # save the old segment to the list and reset it
                allWhen.append(when)
                allCoord.append(coord)
                allInd += 1  # increase the allWhen index

                # create the path segment
                trk = currfolder.newgxtrack(name='{0}'.format(when[0]))
                trk.newwhen(when)
                trk.newgxcoord(coord)
                trk.altitudemode = skml.AltitudeMode.absolute
                trk.extrude = 1

                # choose style based on estimated or true
                if estimated == 0:
                    trk.stylemap = goodstyle
                    # trk.stylemap.normalstyle = goodstyle
                    # trk.stylemap.highlightstyle = goodstyle
                else:
                    trk.stylemap = badstyle
                    # trk.stylemap.normalstyle = badstyle
                    # trk.stylemap.highlightstyle = badstyle

                # set the estimated state to the current state
                estimated = est

                coord = []
                when = []
                createNewSegment = False

                # handle the segment ind change over here
                # since it will also be used to create a new folder
                if segmentInd != seg:
                    segmentInd = seg
                    currfolder = fol.newfolder(name='{0}'.format(segmentInd))

            # add the points to the arrays (done at all times at this point)
            when.append(tstring)
            coord.append((lon, lat, alt))

    #
    # add the last set of points
    #

    # if we are currently in an estimated track, want to add the last
    # point of the previous segment to get the correct segment
    if estimated == 1:
        # also want to add the last point from the previous segment
        lastWhen = allWhen[allInd-1]
        lastCoord = allCoord[allInd-1]
        when.insert(0, lastWhen[-1])
        coord.insert(0, lastCoord[-1])

    allWhen.append(when)
    allCoord.append(coord)
    trk = currfolder.newgxtrack(name='{0}'.format(when[0]))
    trk.newwhen(when)
    trk.newgxcoord(coord)
    trk.altitudemode = skml.AltitudeMode.absolute
    trk.extrude = 1

    # choose style based on estimated or true
    if estimated == 0:
        trk.stylemap = goodstyle
        # trk.stylemap.normalstyle = goodstyle
        # trk.stylemap.highlightstyle = goodstyle
    else:
        trk.stylemap = badstyle
        # trk.stylemap.normalstyle = badstyle
        # trk.stylemap.highlightstyle = badstyle





# get the name of the output filename
outfilename = sys.argv[1]

# get all the CSV files in the current directory
allFiles = glob.glob(os.path.join('kml-data', '*.csv'))  # find all the csv files

#
# Setup KML
#

# Create the KML document (set it to open its contents when opened in GE)
kml = skml.Kml(name='Flights', open=1)
doc = kml.document  # get the default created document

# set the initial camera view to be over Hayward Airport
doc.camera.latitude = 37.659
doc.camera.longitude = -122.122
doc.camera.altitude = 10000
doc.camera.tilt = 0
doc.camera.heading = 0
doc.camera.roll = 0
doc.camera.altitudemode = skml.AltitudeMode.relativetoground
# doc.camera.gxtimestamp.when = when[0]  # set the time to only show the first bit

# setup the style to be used for all the segments
opacity = 180
width = 2
styleGreen = skml.Style()
styleGreen.linestyle.color = skml.Color.green
styleGreen.polystyle.color = skml.Color.changealphaint(opacity, skml.Color.forestgreen)
styleGreen.linestyle.width = width
styleGreen.iconstyle.scale = 0
styleGreen.iconstyle.icon = None  #.href = 'http://earth.google.com/images/kml-icons/track-directional/track-0.png'
styleGreen.labelstyle.scale = 0

stylemapGreen = skml.StyleMap()
stylemapGreen.normalstyle = styleGreen
stylemapGreen.highlightstyle = styleGreen

styleRed = skml.Style()
styleRed.linestyle.color = skml.Color.red
styleRed.polystyle.color = skml.Color.changealphaint(opacity, skml.Color.maroon)
styleRed.linestyle.width = width
styleRed.iconstyle.scale = 0
styleRed.iconstyle.icon = None  #.href = 'http://earth.google.com/images/kml-icons/track-directional/track-0.png'
styleRed.labelstyle.scale = 0

stylemapRed = skml.StyleMap()
stylemapRed.normalstyle = styleRed
stylemapRed.highlightstyle = styleRed

# loop through all the files creating a folder for every flight
for filename in allFiles:
    generateKMLForFlight(doc, filename, stylemapGreen, stylemapRed)

# NOTE: going to output to the same directory
# Save the kml to file
kml.save(outfilename)
