extends TileMap

#Script vars
var noise_raw =[]
var noise_norm = []
var raw_noise_max
var temp = []
var elevation = []
var moisture =[]
var r_lat =[]
var UI_path = "/root/MainScene/UI/MapOptions"

#start functions
func _ready():
	randomize()

func _on_Button_Create_pressed():
	make_map()

func _process(_delta):
	if Input.is_action_just_pressed("map_gen"):
		make_map()

func _input(event):
	if Input.is_action_just_pressed("rightclick"):
		var mouse_pos = event.position
		var tile_pos = world_to_map(mouse_pos)
		var tilex: int = tile_pos.x
		var tiley: int = tile_pos.y
		get_node("/root/MainScene/UI/TileReadout/elevation_reading").text = var2str(elevation[tilex][tiley])
		get_node("/root/MainScene/UI/TileReadout/temp_reading").text = var2str(temp[tilex][tiley])
		get_node("/root/MainScene/UI/TileReadout/moist_reading").text = var2str(moisture[tilex][tiley])
		get_node("/root/MainScene/UI/TileReadout/noise_reading").text = var2str(noise_norm[tilex][tiley])
		print ("Raw max: ",raw_noise_max)
		var norm_noise_max = noise_norm.max().max()
		print ("norm max: ",norm_noise_max)

func make_map():
	#clear tilemap
	clear()
	
	#get vars
	var map_size = get_node(UI_path+"/SpinBox_Size").value
	var octaves = int(get_node(UI_path+"/SpinBox_Octaves").value)
	var period = float(get_node(UI_path+"/SpinBox_Period").value)
	var persistance = float(get_node(UI_path+"/SpinBox_Persistance").value)
	var lacunarity = float(get_node(UI_path+"/SpinBox_Lacunarity").value)
	var ElPower = int(get_node(UI_path+"/optbutton_ElevPower").text)
	var landsizeselected = get_node(UI_path+"/ItemList_LandSize").selected
	var climate = get_node(UI_path+"/Climate_HSlider").value
	var sealvl = get_node(UI_path+"/SeaLevel_HSlider").value
	var landarray = [72, 29,14,7,3]
	var landsize = landarray[landsizeselected] 
	var latPtile = landsize/map_size
	var latadj = (180-landsize)*climate
	var MpT = round(latPtile*69)
	get_node(UI_path+"/MpT_Display").text = var2str(MpT)

	#set noise parameters
	var noise = OpenSimplexNoise.new()
	
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
	
	# get raw noise values
	noise_raw.resize(map_size)
	for n in map_size:
		noise_raw[n] = []
		noise_raw[n].resize(map_size)
		for m in map_size:
			noise_raw[n][m] = (noise.get_noise_2d(n,m))

	# normalize noise values
	raw_noise_max = noise_raw.max().max()
	noise_norm.resize(map_size)
	for n in map_size:
		noise_norm[n] = []
		noise_norm[n].resize(map_size)
		for m in map_size:
			noise_norm[n][m] = (noise_raw[n][m]/raw_noise_max)

	# set elevation
	elevation.resize(map_size)
	for n in map_size:
		elevation[n] = []
		elevation[n].resize(map_size)
		for m in map_size:
			elevation[n][m] = pow(noise_norm[n][m], ElPower)

	#set base temperatures
	temp.resize(map_size)
	for n in map_size:
		temp[n] = []
		temp[n].resize(map_size)
		for m in map_size:
			temp[n][m] = 30-(45*pow(sin(r_lat[n][m]),2)) - clamp(elevation[n][m]*40,0,100)

	#set base moisture
	moisture.resize(map_size)
	for n in map_size:
		moisture[n] = []
		moisture[n].resize(map_size)
		for m in map_size:
			moisture[n][m] = (25*sin(6*r_lat[n][m]+1.65))+25 + clamp((elevation[n][m]*10),0,10)

	#choose tiles
	for n in range(0,map_size-1):
		for m in range(0,map_size-1):
			if temp[n][m] <-14.7:
				set_cell(n,m,0)
			elif elevation[n][m] <= sealvl and temp[n][m] <= -13:
				set_cell(n,m,1)
			elif elevation[n][m] <= sealvl and temp[n][m] > -13:
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
