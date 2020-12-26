#bash script for sailfishos fingerterm
#he script maps the same source to a pair of wired headphones and bluetooth headphones
#that are connected to the same sailfish device, so that two people can listen to the
#same audio simultaneously.
#two notes:
#at first it was difficult to get primary_output sink to always map to headphones if
#plugged in, so now that's forced by the set_sink function
#also it started mapping the source to both primary_output and deep_buffer which caused
#funky artefacts in the headphones (in particular the deep_buffer has larger latency).
#this should now also be fixed
function set_sink {
	echo "Setting default sink to $1";
	pacmd set-default-sink $1
	pacmd set-sink-port 0 output-wired_headphone
	pacmd list-sink-inputs | grep index | while read line
	do
		echo "Moving input:";
		echo $line | cut -f2 -d' ';
		echo "to sink $sink_number";
		pacmd move-sink-input `echo $line | cut -f2 -d' '` $1
		pacmd set-sink-mute 1 1
	done
}
sink_number=`pacmd list-sinks | grep -B 1 "combined" | cut -f1 | grep -Eo ".$"`
if pacmd list-sinks  | grep -q combined";
then set_sink $sink_number
else find_bt_sink_name=`pacmd list-sinks | grep "bluez_sink" | cut -f2`
	mac_address=`echo "{find_bt_sink_name:1}"`
	pacmd load-module module-combine-sink sink_name=combined sink_properties=device.description=CombinedSink slaves=sink.primary_output,bluez_sink.$mac_addressa2dp_sink
	set_sink $sink_number
fi
