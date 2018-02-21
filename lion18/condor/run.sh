<<<<<<< HEAD
PROGRAM="$1"
SEED="$2"
CONFIG="$3"
echo "./$PROGRAM --config $CONFIG --seed $SEED"
./$PROGRAM --config $CONFIG --seed $SEED
=======
#!/bin/bash

PROGRAM="$1"
SEED="$2"
CONFIG="$3"
echo "./$PROGRAM --config $CONFIG -seed $SEED"
./$PROGRAM --config $CONFIG -seed $SEED
>>>>>>> 5d340178494faf75fc5bf7acba1ff4d7fae29553

