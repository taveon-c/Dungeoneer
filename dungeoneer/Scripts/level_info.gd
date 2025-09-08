extends Resource
class_name LevelInfo

@export var MAP_HEIGHT : int
@export var MAP_WIDTH : int
@export var HALL_LENGTH : int
@export var ROOM_RADII_MAX : int
@export var ROOM_RADII_MIN : int
@export var NUM_HALLS_MAX : int
@export var NUM_ROOMS_MIN : int
@export var NUM_ROOMS_MAX : int
@export var MIN_ENEMY : int
@export var MAX_ENEMY : int
@export var TILE_SIZE : int
@export var MIN_NUM_WEAPONS : int
@export var MAX_NUM_WEAPONS : int
@export var ENEMY_SCENES : PackedScene
@export var WEAPON_PICKUP_SCENE : PackedScene
@export var WEAPONS : Array[Weapon]
var astar_grid : AStarGrid2D = AStarGrid2D.new()
