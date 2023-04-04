local pdf = require("justenoughlibtexpdf")

local plain = require("classes.plain")
local class = pl.class(plain)
class._name = "sine"

class.defaultFrameset = {} -- See class:declareFrames()
class.firstContentFrame = "page1"

local function markings()
  local page = assert(SILE.getFrame("page"))

  local w = page:width()
  local h = page:height()
  SILE.outputter:drawRule(w/2-0.5, 0, 1, h)
  for y = 0, 3 do
    SILE.outputter:drawRule(0, h*y/4-0.5, w, 1)
  end
end

local enter = function (self, typesetter)
  if not self.orientation then return end

  local angles = {
    right = 90,
    left = -90,
    down = 0,
  }

  if self.orientation == "down" then
    return
  end

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

  if self.orientation == "down" then
    return
  end

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
  self:loadPackage("image")

  self:loadPackage("sections")
  self:loadPackage("figure")

  table.insert(SILE.framePrototype.enterHooks, enter)
  table.insert(SILE.framePrototype.leaveHooks, leave)

  SILE.scratch.counters.folio.off = true

  markings()
  plain.registerHook(self, "newpage", markings)
end

function class:declareOptions ()
  plain.declareOptions(self)

  self:declareOption("gutter", function (_, value)
    if value then
      SILE.settings:set("sine.gutter", value, true)
    end
    return SILE.settings:get("sine.gutter")
  end)

  self:declareOption("margin-mid", function (_, value)
    if value then
      SILE.settings:set("sine.margin-mid", value, true)
    end
    return SILE.settings:get("sine.margin-mid")
  end)

  for i = 1, 8 do
    self:declareOption("page"..i.."orientation", function (_, value)
      if value then
        SILE.settings:set("sine.page"..i.."orientation", value, true)
      end
      return SILE.settings:get("sine.page"..i.."orientation")
    end)
  end
end

function class:declareSettings()
  plain.declareSettings(self)

  SILE.settings:declare({
    parameter = "sine.gutter",
    type = "measurement",
    default = SILE.measurement("7mm"),
    help = "Distance between each frame",
  })

  SILE.settings:declare({
    parameter = "sine.margin-mid",
    type = "measurement",
    default = SILE.measurement("10mm"),
    help = "Distance between the left frame column and the right frame column",
  })

  for i = 1, 8 do
    local def = "left"
    if i >=4 and i ~= 8 then
      def = "right"
    end
    SILE.settings:declare({
      parameter = "sine.page"..i.."orientation",
      type = "string",
      default = def,
      help = "Orientation of the "..i.."th content frame",
    })
  end
end

function class:registerCommands()
  plain.registerCommands(self)

  self:registerCommand("noindent", function (_, content)
    if #SILE.typesetter.state.nodes ~= 0 then
      SU.warn("\\noindent called after nodes already recieved in a paragraph, the setting will have no effect because the parindent (if any) has already been output")
    end
    local parident = SILE.settings:get("current.parindent")
    SILE.settings:set("current.parindent", SILE.nodefactory.glue())
    SILE.process(content)
    SILE.settings:set("current.parindent", parident)
  end, "Do not add an indent to this text")
end

function class:declareFrames()
  local gutter = SILE.settings:get("sine.gutter")
  local marginMid = SILE.settings:get("sine.margin-mid")

  self.defaultFrameset = {
    page8 = {
      top = "0%ph+"..gutter.."/2",
      left = "0%pw+"..gutter,
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      orientation = SILE.settings:get("sine.page8orientation"),
    },
    page1 = {
      top = "25%ph+"..gutter.."/2",
      left = "0%pw+"..gutter,
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page2",
      orientation = SILE.settings:get("sine.page1orientation"),
    },
    page2 = {
      top = "50%ph+"..gutter.."/2",
      left = "0%pw+"..gutter,
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page3",
      orientation = SILE.settings:get("sine.page2orientation"),
    },
    page3 = {
      top = "75%ph+"..gutter.."/2",
      left = "0%pw+"..gutter,
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page4",
      orientation = SILE.settings:get("sine.page3orientation"),
    },
    page7 = {
      top = "0%ph+"..gutter.."/2",
      left = "50%pw".."+"..marginMid.."/2",
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page8",
      orientation = SILE.settings:get("sine.page7orientation"),
    },
    page6 = {
      top = "25%ph+"..gutter.."/2",
      left = "50%pw".."+"..marginMid.."/2",
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page7",
      orientation = SILE.settings:get("sine.page6orientation"),
    },
    page5 = {
      top = "50%ph+"..gutter.."/2",
      left = "50%pw".."+"..marginMid.."/2",
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      next = "page6",
      orientation = SILE.settings:get("sine.page5orientation"),
    },
    page4 = {
      top = "75%ph+"..gutter.."/2",
      left = "50%pw".."+"..marginMid.."/2",
      width = "50%pw-("..gutter.."+"..marginMid.."/2)",
      height = "25%ph-"..gutter,
      orientation = SILE.settings:get("sine.page4orientation"),
      next = "page5",
    },
  }

  plain.declareFrames(self, self.defaultFrameset)
end

return class