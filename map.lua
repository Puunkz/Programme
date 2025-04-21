local map = {}

map.init = function ()
    map.load() 
end

map.load = function()
    map.img = love.graphics.newImage("assets/images/map.png")
    map.width = map.img:getWidth()
    map.height = map.img:getHeight()
   
    if SCREEN_SIZE and SCREEN_SIZE.width and SCREEN_SIZE.height then
        map.x = SCREEN_SIZE.width /2 - map.width /2
        map.y = SCREEN_SIZE.height /2 - map.height /2
    else
        map.x = 0
        map.y = 0
    end
end

map.draw = function()
    love.graphics.draw(map.img, map.x, map.y, 0)
end
return map