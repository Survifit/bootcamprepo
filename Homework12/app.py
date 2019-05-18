from flask import Flask, render_template, redirect
from flask_pymongo import PyMongo
import scrape_mars

app = Flask(__name__)

# Use flask_pymongo to set up mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/mars_db"
mongo = PyMongo(app)


@app.route("/")
def index():
    # Use try/except so application can run with an empty database, if no data is present it will be scraped before loading
    try:
        mars_info = mongo.db.new_info.find_one()
        return render_template("index.html", mars_info=mars_info)
    except:
        new_info = mongo.db.new_info
        new_info_update = scrape_mars.scrape()
        new_info.update({}, new_info_update, upsert=True)
        return redirect("/", code=302)

@app.route("/scrape")
def scraper():
    new_info = mongo.db.new_info
    new_info_update = scrape_mars.scrape()
    new_info.update({}, new_info_update, upsert=True)
    return redirect("/", code=302)


if __name__ == "__main__":
    app.run(debug=True)
