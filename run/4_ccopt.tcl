set_ccopt_mode -cts_buffer_cells BUFF \
               -cts_inverter_cells INV \
	       -cts_use_min_max_path_delay false \
	       -cts_target_slew 10 \
	       -cts_target_skew 50 \
	       -modify_clock_latency true
create_ccopt_clock_tree_spec -file ../data/top-ccopt_cts.spec
create_ccopt_clock_tree_spec
clock_opt_design
