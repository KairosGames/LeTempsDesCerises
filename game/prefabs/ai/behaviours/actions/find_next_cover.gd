@tool
class_name FindNextCover extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var current_cover: Cover = agent.cover
	if not current_cover: 
		printerr("%s has no current cover" % agent.name)
		return FAILURE
	var next_cover: Cover = null
	for cover: Cover in current_cover.next_covers:
		if not cover.enabled: continue
		if CoverManager.is_free(cover):
			next_cover = cover
			break
	if next_cover:
		blackboard.set_value("cover", next_cover)
		return SUCCESS
	else:
		return FAILURE
