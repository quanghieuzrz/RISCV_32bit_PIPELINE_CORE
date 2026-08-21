# filelist.f
# List of all source files in the project, each file listed exactly once.
# Order does not matter for most simulators (iverilog, Vivado xsim, ModelSim...)
# because they all perform 2-pass elaboration (scans module names first, links later).

# ---- Leaf modules (do not depend on any other modules) ----
src/PC.v
src/PC_Adder.v
src/Mux_Fetch.v
src/Instruction_Memory.v
src/IF_ID_Register.v
src/ALU.v
src/Main_Decoder.v
src/Alu_Decoder.v
src/Register_File.v
src/Sign_Extend.v
src/ID_EX_Register.v
src/Data_Memory.v
src/Hazard_Unit.v

# ---- Mid-level modules (instantiate the leaf modules above) ----
src/Control_Unit_top.v
src/Fetch_Cycle.v
src/Decode_Cycle.v
src/Execute_Cycle.v
src/Memory_Cycle.v
src/Write_Back.v

# ---- Top-level ----
src/Pipeline_top.v

# ---- Testbench (Uncomment the active testbench for simulation) ----
# sim/pipeline_tb.v
# sim/Fetch_Cycle_tb.v
# sim/Decode_Cycle_tb.v
# sim/Execute_Cycle_tb.v
# sim/Memory_Cycle_tb.v
# sim/Write_Back_tb.v
# sim/Hazard_Unit_tb.v