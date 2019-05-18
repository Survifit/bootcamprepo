# Dependencies
from bs4 import BeautifulSoup
from splinter import Browser
import pandas as pd
import requests
import pymongo

def init_browser():
    
    executable_path = {"executable_path": "C:\chromedrv\chromedriver.exe"}
    return Browser("chrome", **executable_path, headless=True)

def scrape():

    # Mars Latest News
    news_url = 'https://mars.nasa.gov/news/'
    news_resp = requests.get(news_url)
    news_soup = BeautifulSoup(news_resp.text, 'lxml')
    headline = news_soup.find('div', class_="slide")
    news_title = headline.find('div', class_="content_title").text.strip('\n')
    news_summary = headline.find('div', class_="rollover_description_inner").text.strip('\n')
    
    # JPL Mars Space Images - Featured
    image_url = 'https://www.jpl.nasa.gov/spaceimages/?search=&category=Mars#submit'
    image_resp = requests.get(image_url)
    image_soup = BeautifulSoup(image_resp.text, 'lxml')
    image = image_soup.find('li', class_='slide')
    featured_image_url = "https://www.jpl.nasa.gov" + image.a['data-fancybox-href']

    # Twitter weather report for Mars
    twitter_url = 'https://twitter.com/marswxreport?lang=en'
    twitter_resp = requests.get(twitter_url)
    twitter_soup = BeautifulSoup(twitter_resp.text, 'lxml')
    tweets = twitter_soup.find_all('div', class_='content')
    for tweet in tweets:
        if tweet.a['href'] == '/MarsWxReport':
            recent_tweet = tweet
            break
    mars_weather = recent_tweet.p.text
    # Remove un-usable picture URL from the end of the tweet
    mars_weather = mars_weather.partition(' hPapic')[0]

    # Mars facts table
    facts_url = 'https://space-facts.com/mars/'
    mars_table = pd.read_html(facts_url)
    mars_df = mars_table[0]
    mars_df = mars_df.rename(columns={0:'description',1:'values'})
    mars_df = mars_df.set_index('description')
    mars_df = mars_df.to_html()

    # Mars Hemispheres Images
    browser = init_browser()

    hemi_url = 'https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars'
    hemi_list = ['Cerberus', 'Schiaparelli', 'Syrtis', 'Valles']
    hemisphere_image_urls = []
    browser.visit(hemi_url)

    for hemi in hemi_list:
        browser.click_link_by_partial_text(hemi)
        hemi_html = browser.html
        hemi_soup = BeautifulSoup(hemi_html, 'html.parser')
        url = hemi_soup.find('div', class_='downloads').ul.li.a['href']
        name = hemi_soup.title.text.partition(' Enhanced')[0]
        hemisphere_image_urls.append({'title':name, 'img_url':url})
        browser.back()

    # close browser process
    browser.quit()
    
    # Create master dictionary to load in database
    post = {
        'news': {'title':news_title, 'summary':news_summary},
        'feat_img': featured_image_url,
        'weather': mars_weather,
        'facts': mars_df,
        'hemi_img': hemisphere_image_urls
    }

    return post