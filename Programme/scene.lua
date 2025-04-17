local scene = {}
local font = love.graphics.newFont(32)
local backgroundImage
local winImage
local loseImage

scene.dronesDestroyed = 0

scene.load = function ()
    scene.backgroundMusic = love.audio.newSource("assets/musique/Musique_menu.ogg", "stream")
    scene.gameMusic = love.audio.newSource("assets/musique/Musique_jeu.ogg", "stream")
    scene.gameWinMusic = love.audio.newSource("assets/musique/Musique_win.ogg", "stream")
    scene.gameLoseMusic = love.audio.newSource("assets/musique/Musique_lose.ogg", "stream")
    scene.currentScene = "menu"
    backgroundImage = love.graphics.newImage("assets/images/background.png")
    winImage = love.graphics.newImage("assets/images/youwin.png")
    loseImage = love.graphics.newImage("assets/images/gameover.png")
end

scene.draw = function()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    if scene.currentScene == "menu" then
        love.graphics.draw(backgroundImage, 0, 0, 0, SCREEN_SIZE.width / backgroundImage:getWidth(), SCREEN_SIZE.height / backgroundImage:getHeight())
        love.graphics.printf("Press SPACE to start", 0, SCREEN_SIZE.height / 2 - 20, SCREEN_SIZE.width, "center")
    end

    if scene.currentScene == "win" then
        love.graphics.draw(winImage, 0, 0, 0, SCREEN_SIZE.width / winImage:getWidth(), SCREEN_SIZE.height / winImage:getHeight())
        love.graphics.printf("You destroyed " .. scene.dronesDestroyed .. " drones!", 0, SCREEN_SIZE.height - 200, SCREEN_SIZE.width, "center")
        love.graphics.printf("Press Escape to menu", 0, SCREEN_SIZE.height - 150, SCREEN_SIZE.width, "center")
        
    end

    if scene.currentScene == "lose" then
        love.graphics.draw(loseImage, 0, 0, 0, SCREEN_SIZE.width / loseImage:getWidth(), SCREEN_SIZE.height / loseImage:getHeight())
        love.graphics.printf("You destroyed " .. scene.dronesDestroyed .. " drones!", 0, SCREEN_SIZE.height - 200, SCREEN_SIZE.width, "center")
        love.graphics.printf("Press Escape to menu", 0, SCREEN_SIZE.height - 150, SCREEN_SIZE.width, "center")
    end
end

scene.keypressed = function(key)
    if scene.currentScene == "menu" and key == "space" then
        scene.currentScene = "game"
    end
end

scene.checkCondition = function(tank)
    if tank.body.vie <= 0 then
        scene.currentScene = "lose"
    end
    if scene.dronesDestroyed >= 25 then
        scene.currentScene = "win"
    end
end

return scene