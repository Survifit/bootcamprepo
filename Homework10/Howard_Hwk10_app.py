# Week 10 Homework - SQALCHEMY
# UofMN Data Visualization and Analytics Bootcamp
# Created by Chris Howard
# 05/04/2019

import numpy as np
import datetime as dt

import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func

from flask import Flask, jsonify

# Adding this - DL
from sqlalchemy.orm import scoped_session, sessionmaker

#################################################
# Database Setup
#################################################
engine = create_engine("sqlite:///Resources/hawaii.sqlite")


# Adding this - DL
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# Save reference to the table
Measurement = Base.classes.measurement
Station = Base.classes.station

#################################################
# Flask Setup
#################################################
app = Flask(__name__)


#################################################
# Flask Routes
#################################################

@app.route("/")
def welcome():
    """List all available api routes."""
    return (
        f"<br>"
        f"<h3>Available Routes:</h3>"
        f"<ul><li>/api/v1.0/precipitation</li>"
        f"<li>/api/v1.0/stations</li>"
        f"<li>/api/v1.0/tobs</li><br>"
        f"<strong>For routes below, enter start-date & end-date as yyyy-mm-dd</strong><br><br>"
        f"<li>/api/v1.0/start-date</li>"
        f"<li>/api/v1.0/start-date/end-date</li></ul>"
    )


@app.route("/api/v1.0/precipitation")
def precipitation():
    """Return precipitation as date:prcp dictionary"""
    # Query all measurements
    results = db_session.query(Measurement.date, Measurement.prcp).all()

    # Convert list of tuples into list of dictionaries (can't be single dict due to duplicate keys)
    allPrcp = []
    for row in results:
        tmpDict = {row[0]:row[1]}
        allPrcp.append(tmpDict)
        
    return jsonify(allPrcp)


@app.route("/api/v1.0/stations")
def stations():
    """Return a JSON list of all stations (Showing name and station)"""
    # Query all stations
    results = db_session.query(Station.station, Station.name).all()

    # Create a dictionary from the row data
    allStations = {}
    for row in results:
        allStations.update({row[0]:row[1]})

    return jsonify(allStations)


@app.route("/api/v1.0/tobs")
def tobs():
    """Return a JSON list of all temperature readings in the past 365 days"""
    # Determine most recent date in DB and find date 365 days prior
    most_recent = db_session.query(Measurement.date).order_by(Measurement.date.desc()).first()[0].split('-')
    year_ago = dt.date(int(most_recent[0]), int(most_recent[1]), int(most_recent[2])) - dt.timedelta(days=365)

    # Collect all tobs from the past year
    results = db_session.query(Measurement.date, Measurement.prcp).filter(Measurement.date >= str(year_ago)).all()
    
    # Create a dictionary from the row data (remove null values)
    temps = []
    for row in results:
        if row[1] is not None:
            temps.append(row[1])

    return jsonify(temps)


@app.route("/api/v1.0/<start>")
def startTemps(start):
    def calc_temps(start_date):
        sel = [func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)]
        return db_session.query(*sel).filter(Measurement.date >= start_date).all()

    summaryTemps = calc_temps(start)
    summaryDict = ({'Minimum Temp':summaryTemps[0][0],
                    'Average Temp':summaryTemps[0][1],
                    'Maximum Temp':summaryTemps[0][2]})
    
    return jsonify(summaryDict)


@app.route("/api/v1.0/<start>/<end>")
def startEndTemps(start,end):
    def calc_temps(start_date,end_date):
        sel = [func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)]
        return db_session.query(*sel).filter(Measurement.date <= end_date).\
            filter(Measurement.date >= start_date).all()

    summaryTemps = calc_temps(start,end)
    summaryDict = ({'Minimum Temp':summaryTemps[0][0],
                    'Average Temp':summaryTemps[0][1],
                    'Maximum Temp':summaryTemps[0][2]})
    
    return jsonify(summaryDict)

# Adding this - DL
@app.teardown_appcontext
def cleanup(resp_or_exc):
    print('Teardown received')
    db_session.remove()

if __name__ == '__main__':
    app.run(debug=True)
