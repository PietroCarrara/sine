local base = require("packages.base")

local package = pl.class(base)
package._name = "sections"

function package:_init()
  base._init(self)

  SILE.settings:declare({
    parameter = "sections.section-font-size",
    type = "measurement",
    default = SILE.measurement("18pt"),
    help = "Font size for section headers"
  })

  SILE.settings:declare({
    parameter = "sections.subsection-font-size",
    type = "measurement",
    default = SILE.measurement("14pt"),
    help = "Font size for subsection headers"
  })
end

function package:registerCommands()
  self:registerCommand("section", function (_, content)
    SILE.typesetter:leaveHmode()
    SILE.call("goodbreak")
    SILE.call("bigskip")
    SILE.call("noindent")

    SILE.call("font", {size = SILE.settings:get("sections.section-font-size")}, content)

    SILE.call("novbreak")
    SILE.call("bigskip")
    SILE.call("novbreak")
    SILE.typesetter:inhibitLeading()
  end)

  self:registerCommand("subsection", function (_, content)
    SILE.typesetter:leaveHmode()
    SILE.call("goodbreak")
    SILE.call("noindent")
    SILE.call("medskip")

    SILE.call("font", {size = SILE.settings:get("sections.subsection-font-size")}, content)

    SILE.call("novbreak")
    SILE.call("medskip")
    SILE.call("novbreak")
    SILE.typesetter:inhibitLeading()
  end)
end

return package