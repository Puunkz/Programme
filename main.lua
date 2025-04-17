SCREEN_SIZE = { width =  1920, height = 1080 }

local tank = require("tank")
local ennemies = require("ennemies")
local map = require("map")
local scene = require("scene")

resetGame = function()
    tank.init()
    tank.body.vie = 100
    tank.projectiles = {}
    drones = {}
    ennemies.init(tank)
    scene.dronesDestroyed = 0
end

function love.load()
    
    love.window.setMode(SCREEN_SIZE.width, SCREEN_SIZE.height) 
    love.window.setTitle("Thomas The Tank")
    tank.init()
    ennemies.init(tank)
    map.init()
    scene.load(resetGame)
end

function love.update(dt)
    if scene.currentScene == "game" then
        love.audio.play(scene.gameMusic)
        love.audio.setVolume(0.5)

        ennemies.update(dt)

        if love.keyboard.isDown("z") then
            tank.moveForward(dt)
        elseif love.keyboard.isDown("s") then
            tank.moveBackward(dt)
        end

        if love.keyboard.isDown("q") then
            tank.rotateLeft(dt)
        elseif love.keyboard.isDown("d") then
            tank.rotateRight(dt)
        end 
    
        if love.keyboard.isDown ("z") == false and love.keyboard.isDown("s") == false then
            tank.stopMoving()
        end

        tank.update(dt)
        scene.checkCondition(tank)
    
    elseif scene.currentScene == "menu" then
        love.audio.play(scene.backgroundMusic)
        love.audio.setVolume(0.2)
    elseif scene.currentScene == "win" then
        love.audio.play(scene.gameWinMusic)
        love.audio.setVolume(0.2)
    elseif scene.currentScene == "lose" then
        love.audio.play(scene.gameLoseMusic)
        love.audio.setVolume(0.2)
    end

    if scene.currentScene == "game" then
        love.audio.stop(scene.backgroundMusic)
    end
    if scene.currentScene == "win" or scene.currentScene == "lose" then
        love.audio.stop(scene.gameMusic)
    end
    if scene.currentScene == "menu" or scene.currentScene == "game" then
        love.audio.stop(scene.gameWinMusic)
        love.audio.stop(scene.gameLoseMusic)
    end
end

function love.draw()
    if scene.currentScene == "game" then
        map.draw()
        tank.draw()
        ennemies.draw()
    elseif scene.currentScene == "menu" or scene.currentScene == "win" or scene.currentScene == "lose"  then
        scene.draw()  
    end
end

function love.keypressed(key)
    if scene.currentScene == "game" or scene.currentScene == "menu" then
        if key == "escape" then
            love.event.quit()
        end
    end

    if scene.currentScene == "win" or scene.currentScene == "lose" then
        if key == "escape" then
            scene.currentScene = "menu"
            scene.dronesDestroyed = 0
            tank.body.vie = 100
            tank.projectiles = {}
            ennemies.drones = {}
        end
    end

    if love.keyboard.isDown("lshift") then
        tank.body.speed = 1000
    elseif love.keyboard.isDown("lshift") == false then
        tank.body.speed = 400
    end
    
    scene.keypressed(key)
end

function love.mousepressed(x, y, button)
    if scene.currentScene == "game" and button == 1 then
        tank.createProjectile()
        love.audio.stop(projectileSound)
        love.audio.play(projectileSound)
        love.audio.setVolume(0.1)
    end
end
