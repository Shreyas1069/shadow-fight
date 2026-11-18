extends RefCounted
class_name FighterIntent

## A small "command message" passed from a controller to a fighter.
##
## This is the key piece that lets keyboard, touch screen and AI all use the
## same fighter code. Every controller builds one of these each frame, and the
## fighter simply reads it. The fighter never reads Input directly.

var move_axis: float = 0.0        # -1 = left, 0 = still, 1 = right
var jump_pressed: bool = false     # true only on the frame the button was pressed
var crouch_held: bool = false      # true while the button is held down
var block_held: bool = false       # true while the button is held down
var attack_1_pressed: bool = false
var attack_2_pressed: bool = false
var sp1_pressed: bool = false
var sp2_pressed: bool = false
