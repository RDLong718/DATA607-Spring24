import requests
import pandas as pd
from bs4 import BeautifulSoup


url = "https://ticker.finology.in/"
r = requests.get(url)
# print(r)

soup = BeautifulSoup(r.text, 'html.parser')

table = soup.find("table",class_ ="table table-sm table-hover screenertable")
headers = table.find_all("th")
# print(headers)

titles=[]

for i in headers:
  title = i.text
  titles.append(title)
  
# print(titles)

df = pd.DataFrame(columns=titles)
print(df)

rows=table.find_all("tr")
for i in rows[1:]:
  print(i)
  data = i.find_all("td")
  row=[]
  for j in data:
    row.append(j.text)
  length = len(df)
  df.loc[length] = row
  print(df)
# remove all instances of "\n" from the dataframe
df = df.replace("\n", "", regex=True)
print(df)
View(df)








