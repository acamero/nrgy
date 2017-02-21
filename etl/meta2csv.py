import sys
import os
import json

meta_folder_name = sys.argv[1] # folder containing metadata
csv_file_name = sys.argv[2] # output file

csv_file = open(csv_file_name, "w")

delimiter = '|'
for subdir, dirs, files in os.walk(meta_folder_name):
    for mfile in files:
        print os.path.join(subdir,mfile)
        with open(os.path.join(subdir,mfile)) as data_file:
            data = json.load(data_file)
            province = data['province'] or ''
            surface = data['surface'] or ''
            address = data['address'] or ''
            lat = data['lat'] or ''
            lng = data['lng'] or ''
            city = data['city'] or ''
            name = data['name'] or ''
            country = data['country'] or ''
            cadastre = data['cadastre'] or ''
            year_of_construct = data['year_of_construct'] or ''
            comments = data['comments'] or ''
            pc = data['pc'] or ''
            state = data['state'] or ''
            csv_file.write( mfile.replace('.json','') + delimiter + province.encode('utf-8') + delimiter + str(surface) + delimiter + address.encode('utf-8') + delimiter + str(lat) + delimiter + str(lng) + delimiter + city.encode('utf-8') + delimiter + name.encode('utf-8') + delimiter + country.encode('utf-8') + delimiter + str(cadastre) + delimiter + str(year_of_construct) + delimiter + comments.encode('utf-8') + delimiter + str(pc) + delimiter + state.encode('utf-8') + '\n' )
        # end with
    # end for
#end for


