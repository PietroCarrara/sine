local base = require("packages.base")

local package = pl.class(base)
package._name = "utils"

local tmpFileCounter = 0

function package:registerCommands()
  self:registerCommand("textarea", function (opts, _)
    local lines = opts.lines or 1

    for i = 1, lines-1 do
      SILE.call("hrulefill")
      SILE.call("novbreak")
      SILE.call("medskip")
      SILE.call("novbreak")
    end
    SILE.call("hrulefill")
  end)

  self:registerCommand("move", function (opts, content)
    local title = opts.title or "untitled"

    SILE.call("marked", {}, function ()
      SILE.typesetter:typeset(title)
    end)
    SILE.call("novbreak")
    SILE.call("smallskip")
    SILE.call("novbreak")
    SILE.process(content)
  end)

  self:registerCommand("attribute", function (opts, content)
    local file = assert(io.open(SILE.resolveFile("attribute.svg"), "r"))
    local contents = file:read("a")
    file:close()

    if opts.name then
      contents = contents:gsub("@NAME@", opts.name)
    end
    if opts.mod then
      contents = contents:gsub("@MOD@", opts.mod)
    end
    if opts.condition then
      contents = contents:gsub("@CONDITION@", opts.condition)
    end

    local svgfname = "/tmp/attribute.svg"
    local svgfile = assert(io.open(svgfname, "w+"))
    svgfile:write(contents)
    svgfile:close()

    local outfname = "/tmp/" .. tmpFileCounter .. ".png"
    local infname = svgfname
    tmpFileCounter = tmpFileCounter + 1

    -- Very, VERY unsafe, but it's the best I've got
    os.execute("inkscape \""..infname.."\" -o \""..outfname.."\" 2>/dev/null")

    opts.src = outfname
    SILE.call("fig", opts, content)
  end)

end

return package