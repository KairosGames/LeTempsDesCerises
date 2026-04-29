@tool
class_name IvyRenderer extends LineRenderer3D

var ivy_gen: PackedScene
var start_pos: Vector3
var deepness: int
var max_deep: int
var dir: Vector3
var var_angle: float
var n_points: int
var dist_btw: float

var childs: Array[IvyRenderer]
var noise: FastNoiseLite = FastNoiseLite.new()

func generate_ivy(
p_ivy_gen: PackedScene,
p_start_pos: Vector3,
i_deep: int,
mx_deep: int,
p_dir: Vector3,
p_angle: float,
p_n_points: int,
p_dist: float,
s_thickness: float,
e_thickness: float) -> void:
	set_strand(p_ivy_gen, p_start_pos, i_deep, mx_deep, p_dir, p_angle, p_n_points, p_dist, s_thickness, e_thickness)
	generate_strand()
	if deepness < max_deep: gen_next_strands()


func set_strand(
p_ivy_gen: PackedScene,
i_p_parent: Vector3,
i_deep: int,
mx_deep: int,
p_dir: Vector3,
p_angle: float,
p_n_points: int,
p_dist: float,
s_thickness: float,
e_thickness: float) -> void:
	ivy_gen = p_ivy_gen
	start_pos = i_p_parent
	deepness = i_deep
	max_deep = mx_deep
	dir = p_dir
	var_angle = p_angle
	n_points = p_n_points
	dist_btw = p_dist
	start_thickness = s_thickness
	end_thickness = e_thickness
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN


func generate_strand() -> void:
	for i in range(0, n_points):
		if points.size() - 1 < i:
			var new_point: Vector3
			points.push_back(new_point)
		if i == 0:
			points[i] = start_pos
			continue
		if i == 1:
			points[i] = points[i-1] + (dir * dist_btw)
			continue
		var angle: float = noise.get_noise_1d(i) * var_angle
		var new_dir: Vector3 = dir.rotated(Vector3.UP, deg_to_rad(angle))
		points[i] = points[i-1] + (new_dir * dist_btw)


func gen_next_strands():
	for i in range(5, points.size(), 5):
		var strand: IvyRenderer = ivy_gen.instantiate() as IvyRenderer
		get_parent().add_child(strand)
		strand.owner = get_parent()
		var pos: Vector3 = points[i]
		var deep: int = deepness + 1
		var new_dir: Vector3 = dir.rotated(Vector3.UP, deg_to_rad(randf_range(-110.0, 110.0)))
		var angle: float = var_angle + 90.0
		var n_p: int = n_points - 10
		var s_thick: float = get_thickness_at_point(i)
		strand.generate_ivy(ivy_gen, pos, deep, max_deep, new_dir, angle, n_p, dist_btw, s_thick, end_thickness)
		
	
