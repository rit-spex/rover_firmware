//////////////////////////////////////////////////////////////////////////////////
// Company: RIT SPEX
// Engineer: Alexander Olds
// 
// Create Date: 02/10/2021 11:13:42 PM
// Design Name: 
// Module Name: roversPackage
// Project Name: urc_rover
// Target Devices: Artix 7 35T
// Tool Versions: Vivado 2020.2
// Description: Package containing global typedefs, functions, and tasks for URC rover
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package roversPackage;

    //basic typedefs
    typedef logic [32:0] bus32_t;
    typedef logic [16:0] bus16_t;
    typedef logic [ 8:0] bus08_t;
    typedef logic [ 4:0] bus04_t;

    //system defines
    //`define DEBUG; //uncomment to enable debug mode, ILAs, etc.
    
    //SIMULATION is defined whenever sim is run in Vivado

endpackage