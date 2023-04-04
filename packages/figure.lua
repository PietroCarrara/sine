local base = require("packages.base")

local package = pl.class(base)
package._name = "figure"

function package:registerCommands()
  self:registerCommand("fig", function (options, _)
    SU.required(options, "src", "including image file")

    local widthMeasure = assert(SU.cast("measurement", options.width or 0))
    local heightMeasure = assert(SU.cast("measurement", options.height or 0))
    if not options.height and not options.width then
      widthMeasure = assert(SU.cast("measurement", "100%fw")) -- default if none provided
    end

    -- Margins
    -- They should be absolute relating to the frame, so we have to compensate
    -- for the default document margins (i.e. we are pottentially shrinking/enlarging
    -- the frame when we choose a different margin, so we have to update what "50%fw"
    -- represents)
    local docMarginX = SILE.settings:get("sine.gutter") / 2
    local docMarginTop = SILE.settings:get("sine.margin-mid") / 2
    local marginX = SU.cast("measurement", options['margin-x'] or docMarginX)
    local marginTop = SU.cast("measurement", options['margin-top'] or docMarginTop)
    -- X movement due to margin
    local xDelta = (marginX - docMarginX):tonumber()
    -- Top movement due to margin
    local topDelta = (marginTop - docMarginTop):tonumber()

    local width = widthMeasure:tonumber()
    -- Update "%fw" (frame width) measures due to margins
    if widthMeasure.unit == "%fw" then
      width = (widthMeasure.amount/100) * (SILE.typesetter.frame:width():tonumber() - xDelta*2)
    end

    local height = heightMeasure:tonumber()
    -- Update "%fh" (frame height) measures due to margins
    if heightMeasure.unit == "%fw" then
      height = (heightMeasure.amount/100) * (SILE.typesetter.frame:height():tonumber() - topDelta*2)
    end

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
        width = box_width / (sx),
        height = box_height / (sy) + topDelta, -- Margin-compensated height
        h = box_height / (sy),
        depth = 0,
        value = src,
        outputYourself = function (node, typesetter, _)
          SILE.outputter:drawImage(node.value, typesetter.frame.state.cursorX+xDelta, typesetter.frame.state.cursorY-node.height+topDelta, node.width, node.h, pageno)
          typesetter.frame:advanceWritingDirection(node.width)
      end})
    end)
  end)
end

return package