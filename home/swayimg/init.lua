swayimg.appid = "swayimg"
swayimg.viewer.loop = false
swayimg.viewer.set_window_background(0xc13e4040)
swayimg.mode = "viewer"
-- swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.default_scale = "fit"
-- 初次打开时并没有按照`fit`来缩放。
swayimg.on_window_resize(function()
  swayimg.viewer.set_fix_scale("fit")
end)
-- swayimg.gallery.enable_embedded_thumb(true)
swayimg.gallery.pstore = true
-- swayimg.gallery.enable_preload(true)
swayimg.gallery.aspect = "fill"
swayimg.gallery.thumb_size = 300
swayimg.gallery.hover = false
swayimg.imagelist.adjacent = true

swayimg.text.visible = false
swayimg.text.font = "monospace"
swayimg.text.size = 26
swayimg.text.color = 0xfff0c30f
swayimg.text.background = 0x30000000

-- swayimg.text.set_shadow(0x300090)

swayimg.viewer.on_key("k", function()
  swayimg.viewer.open("prev")
end)
swayimg.viewer.on_key("j", function()
  swayimg.viewer.open("next")
end)
swayimg.viewer.on_key("r", function()
  swayimg.viewer.rotate(90)
end)
swayimg.viewer.on_key("f", function()
  swayimg.viewer.flip_horizontal()
end)
swayimg.viewer.on_key("q", function()
  swayimg.exit()
end)
swayimg.viewer.on_key("g", function()
  swayimg.mode = "gallery"
end)
swayimg.viewer.on_key("o", function()
  swayimg.mode = "gallery"
end)
swayimg.viewer.on_key("i", function()
  if swayimg.text.visible then
    swayimg.text.visible = false
  else
    swayimg.text.visible = true
  end
end)


swayimg.gallery.on_key("q", function()
  swayimg.exit()
end)
swayimg.gallery.on_key("h", function()
  swayimg.gallery.select("left")
end)
swayimg.gallery.on_key("l", function()
  swayimg.gallery.select("right")
end)
swayimg.gallery.on_key("k", function()
  swayimg.gallery.select("up")
end)
swayimg.gallery.on_key("j", function()
  swayimg.gallery.select("down")
end)
swayimg.gallery.on_key("o", function()
  swayimg.mode = "viewer"
end)
