@tool
class_name KuwaharaCompositorEffect extends CompositorEffect

const SHADER_FILE: RDShaderFile = preload("res://materials/shaders/kuwahara_compositor.glsl")
const BUFFER_CONTEXT: StringName = &"kuwahara"
const INTERMEDIATE_TEXTURE: StringName = &"intermediate"
const WORKGROUP_SIZE: int = 8

static var _dynamic_da: float = 1.0
static var _dynamic_da_mutex: Mutex = Mutex.new()

@export_range(0.0, 1000.0, 0.1, "or_greater", "suffix:m") var distance_fade_start: float = 25.0
@export_range(0.0, 1000.0, 0.1, "or_greater", "suffix:m") var distance_fade_end: float = 60.0
@export_range(0.0, 1.0, 0.01) var far_effect_strength: float = 0.0

var _rendering_device: RenderingDevice
var _shader: RID
var _pipeline: RID
var _depth_sampler: RID


static func set_dynamic_da(value: float) -> void:
	_dynamic_da_mutex.lock()
	_dynamic_da = clampf(value, 0.0, 1.0)
	_dynamic_da_mutex.unlock()


static func _get_dynamic_da() -> float:
	_dynamic_da_mutex.lock()
	var value: float = _dynamic_da
	_dynamic_da_mutex.unlock()
	return value


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	access_resolved_color = true
	access_resolved_depth = true
	_rendering_device = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


func _notification(what: int) -> void:
	if what != NOTIFICATION_PREDELETE or not _rendering_device: return
	if _depth_sampler.is_valid(): _rendering_device.free_rid(_depth_sampler)
	if _shader.is_valid(): _rendering_device.free_rid(_shader)


func _initialize_compute() -> void:
	if not _rendering_device: return
	_shader = _rendering_device.shader_create_from_spirv(SHADER_FILE.get_spirv())
	if not _shader.is_valid():
		push_error("Unable to create the Kuwahara compositor shader")
		return

	_pipeline = _rendering_device.compute_pipeline_create(_shader)
	var sampler_state: RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	_depth_sampler = _rendering_device.sampler_create(sampler_state)


func _render_callback(callback_type: int, render_data: RenderData) -> void:
	if callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT: return
	if not _rendering_device or not _pipeline.is_valid(): return

	var dynamic_da: float = _get_dynamic_da()
	if is_zero_approx(dynamic_da): return

	var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	var render_scene_data: RenderSceneData = render_data.get_render_scene_data()
	if not render_scene_buffers or not render_scene_data: return

	var size: Vector2i = render_scene_buffers.get_internal_size()
	if size.x <= 0 or size.y <= 0: return

	var view_count: int = render_scene_buffers.get_view_count()
	render_scene_buffers.create_texture(
		BUFFER_CONTEXT,
		INTERMEDIATE_TEXTURE,
		RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT,
		RenderingDevice.TEXTURE_SAMPLES_1,
		size,
		view_count,
		1,
		false,
		false
	)

	var group_count_x: int = (size.x - 1) / WORKGROUP_SIZE + 1
	var group_count_y: int = (size.y - 1) / WORKGROUP_SIZE + 1
	var projection: Projection = render_scene_data.get_cam_projection()
	var fade_start: float = minf(distance_fade_start, distance_fade_end)
	var fade_end: float = maxf(distance_fade_start, distance_fade_end)
	if is_equal_approx(fade_start, fade_end): fade_end += 0.001

	for view: int in range(view_count):
		var color_image: RID = render_scene_buffers.get_color_layer(view)
		var depth_image: RID = render_scene_buffers.get_depth_layer(view)
		var intermediate_image: RID = render_scene_buffers.get_texture_slice(
			BUFFER_CONTEXT,
			INTERMEDIATE_TEXTURE,
			view,
			0,
			1,
			1
		)

		var filter_uniform_set: RID = _get_uniform_set(color_image, intermediate_image, depth_image)
		var copy_uniform_set: RID = _get_uniform_set(intermediate_image, color_image, depth_image)
		var compute_list: int = _rendering_device.compute_list_begin()
		_rendering_device.compute_list_bind_compute_pipeline(compute_list, _pipeline)
		_rendering_device.compute_list_bind_uniform_set(compute_list, filter_uniform_set, 0)
		_set_push_constants(compute_list, size, dynamic_da, false, projection, fade_start, fade_end)
		_rendering_device.compute_list_dispatch(compute_list, group_count_x, group_count_y, 1)
		_rendering_device.compute_list_add_barrier(compute_list)
		_rendering_device.compute_list_bind_uniform_set(compute_list, copy_uniform_set, 0)
		_set_push_constants(compute_list, size, dynamic_da, true, projection, fade_start, fade_end)
		_rendering_device.compute_list_dispatch(compute_list, group_count_x, group_count_y, 1)
		_rendering_device.compute_list_end()


func _get_uniform_set(input_image: RID, output_image: RID, depth_image: RID) -> RID:
	var input_uniform: RDUniform = RDUniform.new()
	input_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	input_uniform.binding = 0
	input_uniform.add_id(input_image)

	var output_uniform: RDUniform = RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_uniform.binding = 1
	output_uniform.add_id(output_image)

	var depth_uniform: RDUniform = RDUniform.new()
	depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	depth_uniform.binding = 2
	depth_uniform.add_id(_depth_sampler)
	depth_uniform.add_id(depth_image)

	return UniformSetCacheRD.get_cache(_shader, 0, [input_uniform, output_uniform, depth_uniform])


func _set_push_constants(
	compute_list: int,
	size: Vector2i,
	dynamic_da: float,
	copy_pass: bool,
	projection: Projection,
	fade_start: float,
	fade_end: float
) -> void:
	var push_constants: PackedFloat32Array = PackedFloat32Array([
		float(size.x), float(size.y), dynamic_da, 1.0 if copy_pass else 0.0,
		fade_start, fade_end, far_effect_strength, 0.0,
	])
	var inverse_projection: Projection = projection.inverse()
	for column: Vector4 in [inverse_projection.x, inverse_projection.y, inverse_projection.z, inverse_projection.w]:
		push_constants.append_array([column.x, column.y, column.z, column.w])
	var push_constant_bytes: PackedByteArray = push_constants.to_byte_array()
	_rendering_device.compute_list_set_push_constant(compute_list, push_constant_bytes, push_constant_bytes.size())
