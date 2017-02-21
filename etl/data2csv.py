import sys
import os

data_folder_name = sys.argv[1] # folder containing metadata
csv_file_name = sys.argv[2] # output file

csv_file = open(csv_file_name, "w")

delimiter = ';'
for subdir, dirs, files in os.walk(data_folder_name):
    for mfile in files:
        print os.path.join(subdir,mfile)
        with open(os.path.join(subdir,mfile)) as data_file:
            first = 1
            for line in data_file:
                if first:
                    first = False
                else:
                    csv_file.write( mfile.replace('.csv','') + delimiter + line )
                # end if
            # end for            
        # end with
    # end for
#end for

csv_file.close()
