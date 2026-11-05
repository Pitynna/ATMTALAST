/obj/item/circuit_component/list_literal/wirenet_send
	display_name = "Wirenet передатчик списка элементов"
	desc = "Creates a data packet from a list literal and sends it over WireNet. If an encryption key is set, only receivers with the same key will accept it."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Powernet reference provided by the circuit_component_wirenet_connection component
	var/datum/powernet/connected_powernet

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/list_literal/wirenet_send/Destroy()
	connected_powernet = null
	enc_key = null
	. = ..()

/obj/item/circuit_component/list_literal/wirenet_send/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
	)

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_connection(datum/powernet/new_powernet)
	connected_powernet = new_powernet

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	connected_powernet = null

/obj/item/circuit_component/list_literal/wirenet_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Ключ", PORT_TYPE_STRING)

/obj/item/circuit_component/list_literal/wirenet_send/input_received(datum/port/input/port)
	connected_powernet?.data_transmission(list_output.value, enc_key.value, WEAKREF(list_output))
