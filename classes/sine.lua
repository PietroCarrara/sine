local pdf = require("justenoughlibtexpdf")

local plain = require("classes.plain")
local class = pl.class(plain)
class._name = "sine"

local marginMid = "10mm"
local gutter = "10mm"

class.defaultFrameset = {
  page1 = {
    top = "0%ph+"..gutter.."/2",
    left = "0%pw+"..gutter,
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page2",
    orientation = "left",
  },
  page2 = {
    top = "25%ph+"..gutter.."/2",
    left = "0%pw+"..gutter,
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page3",
    orientation = "left",
  },
  page3 = {
    top = "50%ph+"..gutter.."/2",
    left = "0%pw+"..gutter,
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page4",
    orientation = "left",
  },
  page4 = {
    top = "75%ph+"..gutter.."/2",
    left = "0%pw+"..gutter,
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page5",
    orientation = "left",
  },
  page5 = {
    top = "0%ph+"..gutter.."/2",
    left = "50%pw".."+"..marginMid.."/2",
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page6",
    orientation = "right",
  },
  page6 = {
    top = "25%ph+"..gutter.."/2",
    left = "50%pw".."+"..marginMid.."/2",
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page7",
    orientation = "right",
  },
  page7 = {
    top = "50%ph+"..gutter.."/2",
    left = "50%pw".."+"..marginMid.."/2",
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    next = "page8",
    orientation = "right",
  },
  page8 = {
    top = "75%ph+"..gutter.."/2",
    left = "50%pw".."+"..marginMid.."/2",
    width = "50%pw-("..gutter.."+"..marginMid.."/2)",
    height = "25%ph-"..gutter,
    orientation = "right",
  },
}
class.firstContentFrame = "page1"

local function markings()
  local page = SILE.getFrame("page")
  if page == nil then return end

  local w = page:width()
  local h = page:height()
  SILE.outputter:drawRule(w/2, 0, 1, h)
  for y = 0, 3 do
    SILE.outputter:drawRule(0, h*y/4, w, 1)
  end
end

local enter = function (self, typesetter)
  if not self.orientation then return end

  local angles = {
    right = 90,
    left = -90,
  }

  -- Swap width and height
  local w = self.constraints["width"]
  local h = self.constraints["height"]
  self:relax("width")
  self:relax("height")
  self:constrain("width", h)
  self:constrain("height", w)

  local rad = math.rad(angles[self.orientation])
  local cos = math.cos(rad)
  local sin = math.sin(rad)

  local x = self:left():tonumber()
  local y = self:top():tonumber()
  local midw = self:width():tonumber()/2
  local midh = self:height():tonumber()/2

  pdf:gsave()
  pdf.setmatrix(1, 0, 0, 1, x+midw, -(y+midh))
  pdf.setmatrix(cos, sin, -sin, cos, 0, 0)
  if self.orientation == "left" then
    pdf.setmatrix(1, 0, 0, 1, -x-midh, y+2*midh-midw)
  else
    pdf.setmatrix(1, 0, 0, 1, -x-2*midw+midh, y+midw)
  end
end
local leave = function(self, _)
  if not self.orientation then return end

  pdf:grestore()

  -- Deswap width and height
  local w = self.constraints["width"]
  local h = self.constraints["height"]
  self:relax("width")
  self:relax("height")
  self:constrain("width", w)
  self:constrain("height", h)
end

function class:_init(options)
  plain._init(self, options)

  SILE.outputter:_ensureInit()
  self:loadPackage("frametricks")
  self:loadPackage("lists")

  self:loadPackage("sections")

  table.insert(SILE.framePrototype.enterHooks, enter)
  table.insert(SILE.framePrototype.leaveHooks, leave)

  SILE.scratch.counters.folio.off = true
end

function class:endPage ()
  markings()
  SILE.typesetter.frame:leave(SILE.typesetter)
  self:runHooks("endpage")
end

function class:finish()
  SILE.inputter:postamble()
  SILE.call("vfill")
  while not SILE.typesetter:isQueueEmpty() do
    SILE.call("supereject")
    SILE.typesetter:leaveHmode(true)
    SILE.typesetter:buildPage()
    if not SILE.typesetter:isQueueEmpty() then
      SILE.typesetter:initNextFrame()
    end
  end
  SILE.typesetter:runHooks("pageend") -- normally run by the typesetter
  SILE.typesetter.frame:leave(SILE.typesetter)
  markings()
  self:runHooks("endpage")
  if SILE.typesetter then
    assert(SILE.typesetter:isQueueEmpty(), "queues not empty")
  end
  SILE.outputter:finish()
  self:runHooks("finish")
end

return class