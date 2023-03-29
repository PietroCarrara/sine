local base = require("packages.base")

local package = pl.class(base)
package._name = "sections"

function package:_init()
  base._init(self)

  SILE.settings:declare({
    parameter = "sections.subsection-font-size",
    type = "measurement",
    default = SILE.measurement("14pt"),
    help = "Font size for subsection headers"
  })
end

function package:registerCommands()
  self:registerCommand("sine.section-font", function (_, content)
    SILE.call("font", { size = "18pt" }, content)
  end)

  self:registerCommand("section", function (_, content)
    SILE.typesetter:leaveHmode()
    SILE.call("goodbreak")
    SILE.call("medskip")

    SILE.call("noindent", {}, function ()
      SILE.call("sine.section-font", {}, content)
    end)

    SILE.call("novbreak")
    SILE.call("medskip")
    SILE.call("novbreak")
    SILE.typesetter:inhibitLeading()
  end)

  self:registerCommand("subsection", function (_, content)
    SILE.typesetter:leaveHmode()
    SILE.call("goodbreak")
    SILE.call("medskip")

    SILE.call("noindent", {}, function ()
      SILE.call("font", {size = SILE.settings:get("sections.subsection-font-size")}, content)
    end)

    SILE.call("novbreak")
    SILE.call("medskip")
    SILE.call("novbreak")
    SILE.typesetter:inhibitLeading()
  end)
end

return package