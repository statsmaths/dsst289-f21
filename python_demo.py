#######################################################
# Title: DSST289 in Python
# Author: Taylor Arnold <tarnold2@richmond.edu>
# Date: 29 November 2021

import numpy as np
import pandas as pd

#######################################################
# 00. Reading a tabular data set 
dt = pd.read_csv('notes/data/food.csv')
dt.columns
dt

#######################################################
# 01. Grammar of Graphics
from plotnine import ggplot, geom_point, geom_text, aes

(ggplot(dt, aes('calories', 'sugar', color='factor(food_group)')) +
    geom_point())
(ggplot(dt, aes('calories', 'sugar', color='factor(food_group)')) +
    geom_point() +
    geom_text(aes(label = 'item')))


#######################################################
# 02. Data Verbs

# filter
dt[dt['food_group'] == 'vegetable']

# mutate
dt['calories2'] = dt['calories'] * 2

# group_by and summarize
dt.groupby('food_group')['calories'].agg(['mean'])

# select
dt[['fiber', 'food_group']]

# arrange
dt.sort_values('calories')
dt.sort_values(['calories', 'item'])
dt.sort_values('calories', ascending=False)

#######################################################
# 03. Regular expressions

import re

p = re.compile('<i>')

dt['num_italic'] = [len(list(p.finditer(x))) for x in dt['description']]
dt.groupby('food_group')['num_italic'].agg(['mean']).sort_values('mean')

p = re.compile('\\w+')
words = [list(p.findall(x)) for x in dt['description']]

#######################################################
# 04. Call API and Parse JSON

import json
import requests

res = requests.get(
    'https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam'
)
res

obj = json.loads(res.content)
df = pd.DataFrame(obj, index = [0])
df

#######################################################
# 05. Call API and Parse XML

from lxml import etree

res = requests.get('https://lite.cnn.com/en')
res

obj = etree.HTML(res.content)
elem_li = obj.xpath('//li//a')

df = pd.DataFrame({
    'title': [x.text for x in elem_li],
    'link': [x.values()[0] for x in elem_li]
})
df

#######################################################
# 06. Time Series

from plotnine import geom_line

covid = pd.read_csv(
    'notes/data/france_departement_covid.csv', parse_dates = ['date']
)
rhône = covid[covid['departement'] == '69']

(ggplot(rhône, aes('date', 'hospitalised')) +
    geom_line())

#######################################################
# 07. Spatial Data

import geopandas as gpd
import geoplot
import geoplot.crs as gcrs
import matplotlib.pyplot as plt

geo = gpd.read_file('notes/data/france_departement.geojson')
geo = 

p = geoplot.polyplot(geo[0:96].explode(index_parts = True))
plt.show()



