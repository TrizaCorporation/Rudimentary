local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Dependencies = script:WaitForChild("Dependencies")
local MockDataStoreService = require(Dependencies.MockDataStoreService)
local TaskManager = require(Dependencies.DataStoreTaskManager)
local DecidedDataStore = false

task.spawn(function()
  local suc = pcall(function()
    DataStoreService:GetDataStore("__DataStoreEngine__Test"):SetAsync("__Test__", true)
  end)

  if not suc then
    DataStoreService = MockDataStoreService
  end
  DecidedDataStore = true
end)

local DataStores = {}
local DataStoreEngine = {}
DataStoreEngine.DataStoreTypes = {
  "Regular",
  "Ordered"
}
DataStoreEngine.__index = DataStoreEngine

function DataStoreEngine.new(name:string, type:string)
  assert(DataStores[name] == nil, "A DataStoreInstance with this name already exists.")
  assert(RunService:IsServer(), "DataStoreEngine can only be used on the Server.")
  assert(name and type, "Each DataStoreInstance must have a Name and Type.")
  assert(table.find(DataStoreEngine.DataStoreTypes, type), string.format("%s isn't a valid DataStoreType.", type))
  local self = setmetatable({}, DataStoreEngine)
  task.spawn(function()
    if not DecidedDataStore then
      repeat
        task.wait()
      until DecidedDataStore
    end
    self.DataStore = if type == "Regular" then DataStoreService:GetDataStore(name) else DataStoreService:GetOrderedDataStore(name)
    self.TaskManager = TaskManager.new(self)
  end)
  --self.DataStore = if type == "Regular" then DataStoreService:GetDataStore(name) else DataStoreService:GetOrderedDataStore(name)
  self.Type = type
  self.Cache = {}
  DataStores[name] = self
  return self
end

function DataStoreEngine:SetAsync(key:string, value:any, expediteRequest:boolean)
  if not self.TaskManager then repeat task.wait() until self.TaskManager end
  self.Cache[key] = value
  if expediteRequest then
    self.DataStore:SetAsync(key, value)
  else
    local Signal = self.TaskManager:AddTask("Set", {key = key, value = value})
    return Signal
  end
end

DataStoreEngine.SetData = DataStoreEngine.SetData

function DataStoreEngine:GetAsync(key)
  if not self.TaskManager then repeat task.wait() until self.TaskManager end
  if not self.Cache[key] then
    local Signal = self.TaskManager:AddTask("Get", {key = key})
    local Result = nil
    local SignalFired = false
    Signal:Connect(function(result)
      Result = result
      SignalFired = true
    end)
    repeat
      task.wait()
    until SignalFired
    return Result
  else
    return self.Cache[key]
  end
end

DataStoreEngine.GetData = DataStoreEngine.GetAsync

function DataStoreEngine:GetDataStore(name: string)
  return DataStores[name]
end

return DataStoreEngine