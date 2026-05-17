@tool
class_name TEST_REND extends Path3D

var path_gen: PackedScene
var start_pos: Vector3
var deepness: int
var max_deep: int
var dir: Vector3
var var_angle: float
var n_points: int
var dist_btw: float

var childs: Array[IvyRenderer]
var noise: FastNoiseLite = FastNoiseLite.new()

func generate_path(
p_path_gen: PackedScene,
p_start_pos: Vector3,
i_deep: int,
mx_deep: int,
p_dir: Vector3,
p_angle: float,
p_n_points: int,
p_dist: float) -> void:
	set_strand(p_path_gen, p_start_pos, i_deep, mx_deep, p_dir, p_angle, p_n_points, p_dist)
	generate_strand()
	if deepness < max_deep: gen_next_strands()


func set_strand(
p_path_gen: PackedScene,
i_p_parent: Vector3,
i_deep: int,
mx_deep: int,
p_dir: Vector3,
p_angle: float,
p_n_points: int,
p_dist: float) -> void:
	path_gen = p_path_gen
	start_pos = i_p_parent
	deepness = i_deep
	max_deep = mx_deep
	dir = p_dir
	var_angle = p_angle
	n_points = p_n_points
	dist_btw = p_dist
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN


func generate_strand() -> void:
	for i in range(0, n_points):
		if curve.point_count - 1 < i:
			var new_point: Vector3
			curve.add_point(new_point)
		if i == 0:
			curve.set_point_position(i, start_pos)
			continue
		var prev: Vector3 = curve.get_point_position(i - 1)
		if i == 1:
			curve.set_point_position(i, prev + (dir * dist_btw))
			continue
		var angle: float = noise.get_noise_1d(i) * var_angle
		var new_dir: Vector3 = dir.rotated(Vector3.UP, deg_to_rad(angle))
		curve.set_point_position(i, prev + (new_dir * dist_btw))
	print("prout :", deepness)


func gen_next_strands():
	for i in range(5, curve.point_count, 5):
		var strand: TEST_REND = path_gen.instantiate() as TEST_REND
		get_parent().add_child(strand)
		strand.owner = get_parent()
		var pos: Vector3 = curve.get_point_position(i)
		var deep: int = deepness + 1
		var new_dir: Vector3 = dir.rotated(Vector3.UP, deg_to_rad(randf_range(-110.0, 110.0)))
		var angle: float = var_angle + 90.0
		var n_p: int = n_points - 10
		strand.generate_path(path_gen, pos, deep, max_deep, new_dir, angle, n_p, dist_btw)
		
	
