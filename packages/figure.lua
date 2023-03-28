local base = require("packages.base")

local package = pl.class(base)
package._name = "figure"

function package:registerCommands()
  self:registerCommand("fig", function (options, _)
    SU.required(options, "src", "including image file")
    local width =  SU.cast("measurement", options.width or "100%fw"):tonumber()
    local height = SU.cast("measurement", options.height or 0):tonumber()
    local pageno = SU.cast("integer", options.page or 1)
    local src = SILE.resolveFile(options.src) or SU.error("Couldn't find file "..options.src)
    local box_width, box_height, _, _ = SILE.outputter:getImageSize(src, pageno)

    SILE.call("noindent", {}, function ()
      local sx, sy = 1, 1
      if width > 0 or height > 0 then
        sx = width > 0 and box_width / width
        sy = height > 0 and box_height / height
        sx = sx or sy
        sy = sy or sx
      end

      SILE.typesetter:pushHbox({
        width= box_width / (sx),
        height= box_height / (sy),
        depth= 0,
        value= src,
        outputYourself = function (node, typesetter, _)
          SILE.outputter:drawImage(node.value, typesetter.frame.state.cursorX + 20, typesetter.frame.state.cursorY-node.height, node.width, node.height, pageno)
          typesetter.frame:advanceWritingDirection(node.width)
      end})
    end)
  end)
end

return package