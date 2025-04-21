local scene = require("scene")
local projectileImg = love.graphics.newImage("assets/images/Medium_Shell.png")
projectileSound = love.audio.newSource("assets/sons/submachine-gun.mp3", "static")

local IMAGES_SIZE = 0.5

local tank = {}

tank.init = function ()
    tank.body = tank.createBody()
    tank.turret = tank.createTurret()
    tank.projectiles = {}
end

--fonction du tank
tank.createBody = function()
    local bodyImage = love.graphics.newImage("assets/images/Hull_06.png")
    local body = {
        img = bodyImage,
        offset = {x = bodyImage:getWidth() * 0.42, y = bodyImage:getHeight() * 0.5},
        angle = 0,
        rotationSpeed = 2.5,
        position = {x = SCREEN_SIZE.width * 0.5, y = SCREEN_SIZE.height * 0.5},
        size = IMAGES_SIZE,
        direction = 0,
        speed = 400,
        vie = 100,
    }
    return body
end

--fonction de la tourelle
tank.createTurret = function()
    local turretImage = love.graphics.newImage("assets/images/Gun_07.png")
    local turret = {
        img = turretImage,
        offset = { x = turretImage:getWidth() * 0.25, y = turretImage:getHeight() * 0.5 },
        angle = 0,
        position = { x = SCREEN_SIZE.width * 0.5, y = SCREEN_SIZE.height * 0.5 },
        size = IMAGES_SIZE,
        canonLength = 80,
        firePoint = {x = 0, y = 0} 
    }
    return turret
end

-- fonction du projectile
tank.createProjectile = function()
    local projectile = {
        x = tank.turret.firePoint.x,
        y = tank.turret.firePoint.y,
        angle = tank.turret.angle,
        speed = 800,
        damage = 50,
        img = projectileImg,
        origin = { x = projectileImg:getWidth() * 0.5, y = projectileImg:getHeight() * 0.5 },
        size = IMAGES_SIZE,
    }
    table.insert(tank.projectiles, projectile)
end

--mouvement du tank
tank.update = function(dt)
    if tank.body.direction ~= 0 then
        local dx = math.cos(tank.body.angle) * tank.body.speed * tank.body.direction * dt
        local dy = math.sin(tank.body.angle) * tank.body.speed * tank.body.direction * dt
        tank.body.position.x = math.max(0, math.min(SCREEN_SIZE.width, tank.body.position.x + dx))
        tank.body.position.y = math.max(0, math.min(SCREEN_SIZE.height, tank.body.position.y + dy))
    end

--postion de la tourelle
    tank.turret.position.x = tank.body.position.x
    tank.turret.position.y = tank.body.position.y

--visée de la souris
    local mouseX, mouseY = love.mouse.getPosition()
    local dx = mouseX - tank.body.position.x
    local dy = mouseY - tank.body.position.y
    tank.turret.angle = math.atan2(dy, dx)

--point de tir
tank.turret.firePoint.x = tank.body.position.x + math.cos(tank.turret.angle) * tank.turret.canonLength
tank.turret.firePoint.y = tank.body.position.y + math.sin(tank.turret.angle) * tank.turret.canonLength

--mise a jour du projectile
    for i = #tank.projectiles, 1, -1 do
        local projectile = tank.projectiles[i]
        projectile.x = projectile.x + math.cos(projectile.angle) * projectile.speed * dt
        projectile.y = projectile.y + math.sin(projectile.angle) * projectile.speed * dt

    -- Suppression du projectile s'il sort de l'écran
        if projectile.x < 0 or projectile.x > SCREEN_SIZE.width or projectile.y < 0 or projectile.y > SCREEN_SIZE.height then
            table.remove(tank.projectiles, i)
        end

    --suppression du projectile s'il touche un ennemies
        for n = #drones, 1, -1 do
            local drone = drones[n]
            if projectile.x < drone.x + drone.img:getWidth() /2 and projectile.x > drone.x - drone.img:getWidth() /2 then
                if projectile.y < drone.y + drone.img:getHeight() /2 and projectile.y > drone.y - drone.img:getHeight() /2 then
                    table.remove(tank.projectiles, i)
                    drone.vie = drone.vie - projectile.damage
                    if drone.vie <= 0 then
                        scene.dronesDestroyed = scene.dronesDestroyed + 1
                    end
                end               
            end            
        end
    end
end

--fonction de déplacement du tank
tank.moveForward = function(dt)
    tank.body.direction = 1
end
tank.moveBackward = function(dt)
    tank.body.direction = -1
end
tank.rotateLeft = function(dt)
    tank.body.angle = tank.body.angle - tank.body.rotationSpeed * dt
end
tank.rotateRight = function(dt)
    tank.body.angle = tank.body.angle + tank.body.rotationSpeed * dt
end
tank.stopMoving = function()
    tank.body.direction = 0
end

-- barre hp du tank
local hpBar = function (x, y, width, height, currentHP, maxHP)
    local hpRatio = currentHP / maxHP
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x, y, width * hpRatio, height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", x - 1, y - 1, width + 2, height + 2)
    love.graphics.setColor(1, 1, 1)
end

tank.draw = function()
    love.graphics.setColor(1, 1, 1)

    --tank
    love.graphics.draw(
        tank.body.img, 
        tank.body.position.x, tank.body.position.y, 
        tank.body.angle, 
        tank.body.size, tank.body.size,
        tank.body.offset.x, tank.body.offset.y
    )

    --tourrelle
    love.graphics.draw(
        tank.turret.img, 
        tank.turret.position.x, tank.turret.position.y, 
        tank.turret.angle, 
        tank.turret.size, tank.turret.size,
        tank.turret.offset.x , tank.turret.offset.y
    )

    --projectile
    for _, projectile in ipairs(tank.projectiles) do 
        love.graphics.draw(
        projectile.img,
        projectile.x, projectile.y,
        projectile.angle,
        projectile.size, projectile.size,
        projectile.origin.x, projectile.origin.y
        )
    end

    --compteur de kills
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Drones destroyed: " .. scene.dronesDestroyed .. " /25", 20, 80)

    hpBar(50, 50, 200, 20, tank.body.vie, 100)
end
return tank