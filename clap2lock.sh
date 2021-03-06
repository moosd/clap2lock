#!/bin/bash

AMPLITUDE_THRESHOLD=0.99
ENERGY_THRESHOLD=0.2

control_c()
{
  exit 0
}

trap control_c SIGINT

while true; do
	# Read in some sound!
	( sox -t .wav "|arecord -d 2" -n stat 3>&1 1>&2- 2>&3- ) > /tmp/soxout

	# Extract the max amplitude and RMS amplitude of the recorded data
	INVOL=$(cat /tmp/soxout| grep "Maximum.*amplitude"|tr -d ' ' | cut -d ':' -f 2)
	RMSVOL=$(cat /tmp/soxout| grep "RMS.*amplitude"|tr -d ' ' | cut -d ':' -f 2)

	# If our listening was interrupted, then give up, comment out if needed
	if [ -z "$INVOL" ]; then
		exit 0;
	fi
#	if (( $(echo "$INVOL == 0" | bc -l) )); then
#		exit 0;
#	fi

	# Was it a clap? A characteristic feature is a high max amplitude but a low RMS amplitude.
	if (( $(echo "$INVOL > $AMPLITUDE_THRESHOLD" | bc -l) )); then
		if (( $(echo "$RMSVOL < $ENERGY_THRESHOLD" | bc -l) )); then
			#Run a command once the clap has been detected
			echo "New event!"
			echo $INVOL
			echo $RMSVOL
			echo "---"
			xscreensaver-command -lock
		fi
	fi
done

exit 0
