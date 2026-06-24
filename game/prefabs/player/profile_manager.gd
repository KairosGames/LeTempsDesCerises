class_name ProfileManager extends Control

@onready var bg: TextureRect = %ProfileBackground
@onready var picture: TextureRect = %Picture
@onready var surname: RichTextLabel = %Surname
@onready var job: RichTextLabel = %Job
var bg_mat: ShaderMaterial
var pic_mat: ShaderMaterial
var name_mat: ShaderMaterial
var job_mat: ShaderMaterial

@export_group("Pool References")
@export var men_pics: Array[Texture2D]
@export var men_names: Array[String]
@export var men_jobs: Array[String]
@export var women_pics: Array[Texture2D]
@export var women_names: Array[String]
@export var women_jobs: Array[String]

@export_group("Setings")
@export var fade_time: float = 1.0
@export var interval_time: float = 0.5
@export var display_time: float = 3.0

var b_men_pics: Array[Texture2D]
var b_men_names: Array[String]
var b_men_jobs: Array[String]
var b_women_pics: Array[Texture2D]
var b_women_names: Array[String]
var b_women_jobs: Array[String]

enum Gender { Male, Female, NoBinary}
var twn: Tween


func _ready() -> void:
	b_men_pics = men_pics.duplicate()
	b_men_names = men_names.duplicate()
	b_men_jobs = men_jobs.duplicate()
	b_women_pics = women_pics.duplicate()
	b_women_names = women_names.duplicate()
	b_women_jobs = women_jobs.duplicate()
	b_men_pics.shuffle()
	b_men_names.shuffle()
	b_men_jobs.shuffle()
	b_women_pics.shuffle()
	b_women_names.shuffle()
	b_women_jobs.shuffle()
	bg_mat = bg.material as ShaderMaterial
	pic_mat = picture.material as ShaderMaterial
	name_mat = surname.material as ShaderMaterial
	job_mat = job.material as ShaderMaterial


func load_new_profile(gender: Gender) -> void:
	if gender == Gender.NoBinary: gender = randi_range(0, 1)
	var pic_pool: Array[Texture2D] = b_men_pics if gender == Gender.Male else b_women_pics
	var names_pool: Array[String] = b_men_names if gender == Gender.Male else b_women_names
	var jobs_pool: Array[String] = b_men_jobs if gender == Gender.Male else b_women_jobs
	if pic_pool.is_empty(): refill(0, gender)
	var pic: Texture2D = pic_pool.pop_front()
	if names_pool.is_empty(): refill(1, gender)
	var n_name: String = names_pool.pop_front()
	if jobs_pool.is_empty(): refill(2, gender)
	var n_job: String = jobs_pool.pop_front()
	pic_mat.set_shader_parameter("texture2", pic)
	surname.text = n_name
	job.text = n_job


func refill(type: int, gender: Gender) -> void:
	match type:
		0:
			if gender == Gender.Male:
				b_men_pics = men_pics.duplicate()
				b_men_pics.shuffle()
			else:
				b_women_pics = women_pics.duplicate()
				b_women_pics.shuffle()
		1:
			if gender == Gender.Male:
				b_men_names = men_names.duplicate()
				b_men_names.shuffle()
			else:
				b_women_names = women_names.duplicate()
				b_women_names.shuffle()
		2:
			if gender == Gender.Male:
				b_men_jobs = men_jobs.duplicate()
				b_men_jobs.shuffle()
			else:
				b_women_jobs = women_jobs.duplicate()
				b_women_jobs.shuffle()


func reset_all_parameters() -> void:
	bg_mat.set_shader_parameter("factor", 0.0)
	pic_mat.set_shader_parameter("factor", 0.0)
	name_mat.set_shader_parameter("factor", 0.0)
	job_mat.set_shader_parameter("factor", 0.0)


func launch_new_random_profile(gender: Gender, is_jules: bool = false) -> void:
	load_new_profile(gender)
	if is_jules: surname.text = "Jules"
	if twn: twn.kill()
	reset_all_parameters()
	twn = create_tween()
	twn.tween_property(bg_mat, "shader_parameter/factor", 1.0, fade_time)
	twn.parallel().tween_property(pic_mat, "shader_parameter/factor", 1.0, fade_time)
	twn.parallel().tween_property(name_mat, "shader_parameter/factor", 1.0, fade_time)
	twn.tween_interval(interval_time)
	twn.tween_property(job_mat, "shader_parameter/factor", 1.0, fade_time)
	twn.tween_interval(display_time)
	twn.tween_property(bg_mat, "shader_parameter/factor", 0.0, fade_time)
	twn.parallel().tween_property(pic_mat, "shader_parameter/factor", 0.0, fade_time)
	twn.parallel().tween_property(name_mat, "shader_parameter/factor", 0.0, fade_time)
	twn.parallel().tween_property(job_mat, "shader_parameter/factor", 0.0, fade_time)
