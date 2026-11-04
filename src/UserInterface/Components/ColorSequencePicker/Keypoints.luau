export type Edge = "Start" | "End"

export type Keypoint = {
	Id: number,
	Time: number,
	Color: Color3,
	Edge: Edge?,
}

local MAX_KEYPOINTS = 20

local nextId = 0
local function newId()
	nextId = nextId + 1
	return nextId
end

local function rank(keypoint: Keypoint)
	if keypoint.Edge == "Start" then
		return -1
	elseif keypoint.Edge == "End" then
		return 1
	end
	return 0
end

local Keypoints = {}

Keypoints.MAX_KEYPOINTS = MAX_KEYPOINTS

function Keypoints.new(time: number, color: Color3, edge: Edge?): Keypoint
	return {
		Id = newId(),
		Time = time,
		Color = color,
		Edge = edge,
	}
end

function Keypoints.fromSequence(sequence: ColorSequence): { Keypoint }
	local list = {}
	local raw = sequence.Keypoints
	for i, keypoint in raw do
		local edge: Edge? = if i == 1 then "Start" elseif i == #raw then "End" else nil
		table.insert(list, Keypoints.new(keypoint.Time, keypoint.Value, edge))
	end
	return list
end

function Keypoints.toSequence(list: { Keypoint }): ColorSequence
	local raw = {}
	for _, keypoint in list do
		table.insert(raw, ColorSequenceKeypoint.new(keypoint.Time, keypoint.Color))
	end
	return ColorSequence.new(raw)
end

function Keypoints.sort(list: { Keypoint })
	table.sort(list, function(a, b)
		if a.Time == b.Time then
			if rank(a) == rank(b) then
				return a.Id < b.Id
			end
			return rank(a) < rank(b)
		end
		return a.Time < b.Time
	end)
	return list
end

function Keypoints.find(list: { Keypoint }, id: number?): (Keypoint?, number?)
	for i, keypoint in list do
		if keypoint.Id == id then
			return keypoint, i
		end
	end
	return nil, nil
end

function Keypoints.evaluate(list: { Keypoint }, time: number): Color3
	for i = 1, #list - 1 do
		local a, b = list[i], list[i + 1]
		if time >= a.Time and time <= b.Time then
			local span = b.Time - a.Time
			local alpha = if span > 0 then (time - a.Time) / span else 0
			return a.Color:Lerp(b.Color, alpha)
		end
	end
	return if time <= list[1].Time then list[1].Color else list[#list].Color
end

return Keypoints
