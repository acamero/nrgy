import requests
from datetime import datetime,timedelta
import sys
from lxml import html

min_date_in = sys.argv[1] # min date yyyy-mm-dd
max_date_in = sys.argv[2] # max date yyyy-mm-dd
csv_file_name = sys.argv[3] # output file

min_date = datetime.strptime(min_date_in,'%Y-%m-%d')
max_date = datetime.strptime(max_date_in,'%Y-%m-%d')

csv_file = open(csv_file_name, "w")

tmp_date = min_date
headers = {'Host':'www.tutiempo.net','user-agent':'Mozilla/5.0', 'accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8','Accept-Language':'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3','Referer':'http://www.tutiempo.net/registros/lemg','DNT':'1','Upgrade-Insecure-Requests':'1' }

## Malaga -> 'http://www.tutiempo.net/registros/lemg'
## Granada -> legr
## Sevilla -> lezl
## Cordoba -> leba
## Cadiz, Jerez -> lejr
## Almeria, Huercal Overa -> leam
## Granada, Armilla -> lega
# Jaen
# Cadiz
# Jaen, Linares 
# Huelva
# Cordoba, Cabra

while tmp_date <= max_date:
    print tmp_date.strftime('%Y-%m-%d')
    r = requests.post('http://www.tutiempo.net/registros/lega', data = {'date':tmp_date.strftime('%d-%m-%Y')}, headers=headers)    
    tree = html.fromstring(r.content)
    div = tree.get_element_by_id('HistoricosData')
    trs = div.xpath('.//tr')
    for tr in trs:
        tds = tr.xpath('td')
        if len(tds)==8:
            hora = tds[0].text_content().encode('utf-8')
            #estado = tds[1].xpath('div/@title')[0]
            estado = tds[2].text_content().encode('utf-8')
            temperatura = tds[3].text_content().encode('utf-8').replace('\xc2\xb0C','')
            viento = tds[5].text_content().encode('utf-8')
            humedad = tds[6].text_content().encode('utf-8')
            presion = tds[7].text_content().encode('utf-8')
            csv_file.write( tmp_date.strftime('%Y-%m-%d') + '|' + hora + '|' + estado + '|' + temperatura + '|' + viento + '|' + humedad + '|' + presion + '\n')
    # end for
    tmp_date = tmp_date + timedelta(days=1)
# end while

csv_file.close()
