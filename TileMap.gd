extends TileMap

var noise = OpenSimplexNoise.new()

var temp = []
var elevation = []
var moisture =[]
var r_lat =[]

const ui_path = "/root/MainScene/CanvasLayer/GridContainer/"

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("map_gen"):
		clear()
		make_map()

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = get_viewport().get_mouse_position()
		var tile_pos = map_to_world(world_to_map(mouse_pos))
		print(tile_pos)

func make_map():
	#get vars
	var map_size = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_Size").value
	var octaves = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_Octaves").value
	var period = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_Period").value
	var persistance = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_Persistance").value
	var lacunarity = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_Lacunarity").value
	var ElPower = get_node("/root/MainScene/CanvasLayer/GridContainer/SpinBox_ElevPower").value
	var landsizeselected = get_node("/root/MainScene/CanvasLayer/GridContainer/ItemList_LandSize").selected
	var climate = $"/root/MainScene/CanvasLayer/GridContainer/HSlider".value
	var landarray = [72, 29,14,7,3]
	var landsize = landarray[landsizeselected] 
	var latPtile = landsize/map_size
	var latadj = (180-landsize)*climate
	var MpT = round(latPtile*69)
	get_node("/root/MainScene/CanvasLayer/GridContainer/MpT_Display").text = var2str(MpT)


	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistance
	noise.lacunarity = lacunarity

	
		#set lattitude
	r_lat.resize(map_size)
	for n in map_size:
		r_lat[n] = []
		r_lat[n].resize(map_size)
		for m in map_size:
			r_lat[n][m] = deg2rad((m*latPtile-90)+latadj)
	
	
	# set elevation
	elevation.resize(map_size)
	for n in map_size:
		elevation[n] = []
		elevation[n].resize(map_size)
		for m in map_size:
			elevation[n][m] = pow(noise.get_noise_2d(n, m),ElPower)*5


	#set base temperatures
	temp.resize(map_size)
	for n in map_size:
		temp[n] = []
		temp[n].resize(map_size)
		for m in map_size:
			temp[n][m] = 30-(45*pow(sin(r_lat[n][m]),2)) - (elevation[n][m]*20)

	#set base moisture
	moisture.resize(map_size)
	for n in map_size:
		moisture[n] = []
		moisture[n].resize(map_size)
		for m in map_size:
			moisture[n][m] = (25*sin(6*r_lat[n][m]+1.65))+25 + (elevation[n][m]*1)

	#choose tiles
	for n in range(0,map_size-1):
		for m in range(0,map_size-1):
			if temp[n][m] <-10:
				set_cell(n,m,0)
			elif elevation[n][m] <= .05 and temp[n][m] <= -5:
				set_cell(n,m,1)
			elif elevation[n][m] <= .05 and temp[n][m] > -5:
				set_cell(n,m,2)
			elif temp[n][m] <= -5:
				set_cell(n,m,3)
			elif temp[n][m] <= 0:
				set_cell(n,m,6)
			elif moisture[n][m] <= 7:
				set_cell(n,m,5)
			elif temp[n][m] <= 20 and moisture[n][m] <= 25:
				set_cell(n,m,4)
			elif temp[n][m] <= 20 and moisture[n][m] > 25:
				set_cell(n,m,7)
			elif temp[n][m] > 20 and moisture[n][m] <= 25:
				set_cell(n,m,8)
			elif temp[n][m] > 20 and moisture[n][m] > 25:
				set_cell(n,m,9)
			else: set_cell(n,m,2)


func _on_Button_Create_pressed():
	clear()
	make_map()
