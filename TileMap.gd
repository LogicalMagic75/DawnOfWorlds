extends TileMap

var noise = OpenSimplexNoise.new()

var temp = []
var elevation = []
var moisture =[]


func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("map_gen"):
		clear()
		make_map()

func make_map():
	#get vars
	var map_size = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_Size").value
	var octaves = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_Octaves").value
	var period = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_Period").value
	var persistance = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_Persistance").value
	var lacunarity = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_Lacunarity").value
	var ElPower = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/SpinBox_ElevPower").value
	var landsizeselected = get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/ItemList_LandSize").selected
	var landarray = [72, 29,14,7,3]
	var landsize = landarray[landsizeselected] 
	var latPtile = landsize/map_size
	var latadj = randi()%(180-landsize)
	var MpT = round(latPtile*69)
	get_node("/root/MainScene/ViewportContainer/CanvasLayer/GridContainer/MpT_Display").text = var2str(MpT)


	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistance
	noise.lacunarity = lacunarity

	# set elevation
	elevation.resize(map_size)
	for n in map_size:
		elevation[n] = []
		elevation[n].resize(map_size)
		for m in map_size:
			elevation[n][m] = pow(2.5*(noise.get_noise_2d(n, m))-(2*pow(n-(.5*map_size),2)/pow(map_size,2))-(2*pow(m-(.5*map_size),2)/pow(map_size,2)),ElPower)


	#set base temperatures
	temp.resize(map_size)
	for n in map_size:
		temp[n] = []
		temp[n].resize(map_size)
		for m in map_size:
			temp[n][m] = (50 * cos(deg2rad((m*latPtile)-90+latadj))-20) - (pow(elevation[n][m],2)*35)

	#set base moisture
	moisture.resize(map_size)
	for n in map_size:
		moisture[n] = []
		moisture[n].resize(map_size)
		for m in map_size:
			moisture[n][m] = (25* sin((((m*latPtile)+latadj)*.105)+1.5)+25) + (clamp(elevation[n][m],0,1)*10)

	#choose tiles
	for n in range(0,map_size-1):
		for m in range(0,map_size-1):
			if temp[n][m] <-10:
				set_cell(n,m,0)
			elif elevation[n][m] <= 0 and temp[n][m] <= 0:
				set_cell(n,m,1)
			elif elevation[n][m] <= 0 and temp[n][m] > 0:
				set_cell(n,m,2)
			elif temp[n][m] <= 0:
				set_cell(n,m,3)
			elif temp[n][m] <= 10:
				set_cell(n,m,6)
			elif temp[n][m] > 10 and moisture[n][m] <= 10:
				set_cell(n,m,5)
			elif temp[n][m] <= 20 and moisture[n][m] <= 30:
				set_cell(n,m,4)
			elif temp[n][m] <= 20 and moisture[n][m] > 30:
				set_cell(n,m,7)
			elif temp[n][m] > 20 and moisture[n][m] <= 30:
				set_cell(n,m,8)
			elif temp[n][m] > 20 and moisture[n][m] > 30:
				set_cell(n,m,9)
			else: set_cell(n,m,2)
