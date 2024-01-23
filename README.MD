GRAFIX is an API for developing software for the Tandy 1000/PCjr PC-compatible computers. Without a graphics API, programmers had to create their own drawing routines using BIOS calls, or by writing directly to the frame buffer in main memory. Such low-level programming was difficult and time consuming, so some programming languages came with their own drawing routines, such as the Borland Graphics Interface that came with Borland's "Turbo" products. BGI supported Hercules, CGA, EGA, VGA, and 8514 graphics modes, but not the PCjr/Tandy 1000 graphics modes. GRAFIX provides a similar API that supports the 160×200×16c (Mode 8), 320×200×16c (Mode 9), and Tandy 1000 SL/TL/RL 640×200×16c graphics modes, as well as audio routines for the Tandy 1000/PCjr's 3-voice audio hardware.