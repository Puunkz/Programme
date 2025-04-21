local IMAGES_SIZE = 1.5
local tank = require("tank")

local ennemies = {}
drones = {}

local droneState = {
    IDLE = "idle",
    CHASING = "chasing",
    ATTACKING = "attacking",
    DEAD = "dead",
}

ennemies.init = function(tank)
    drones = {}
    ennemies.body = ennemies.createBody()
    ennemies.tankBody = tank.body 

--reglage et postion des drones au start
    for i = 1, 15 do
        local radius = math.random(200, 500)
        local angle = math.random() * 2 * math.pi
        local x = ennemies.tankBody.position.x + math.cos(angle) * radius
        local y = ennemies.tankBody.position.y + math.sin(angle) * radius
        ennemies.spawn(x, y)
    end
end

ennemies.createBody = function()
    local bodyImage = love.graphics.newImage("assets/images/drone.png")
    return {
        drone_damage = 10,
        attack_range = 200,
        drone_speed = 75,
        drone_vie = 100,
        drone_angle = 0,
        drone_img = bodyImage,
        size = IMAGES_SIZE
    }
end

ennemies.spawn = function(x, y)
    local drone = {
        x = x or 0,
        y = y or 0,
        angle = ennemies.body.drone_angle,
        speed = ennemies.body.drone_speed,
        vie = ennemies.body.drone_vie,
        img = ennemies.body.drone_img,
        size = IMAGES_SIZE,
        state = droneState.IDLE,
        hit = false,
        timer = math.random(1, 3), 
    }
    table.insert(drones, drone)
end

--machine a etats pour les drones
local updateDroneState = function(drone)
    local tank = ennemies.tankBody
    if not tank or not tank.position then return 0, 0, 0 end

    local dx = tank.position.x - drone.x
    local dy = tank.position.y - drone.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if drone.vie <= 0 then
        drone.state = droneState.DEAD
        return distance, 0, 0
    end

    if drone.state == droneState.IDLE and distance < 500 then
        drone.state = droneState.CHASING
    elseif drone.state == droneState.CHASING then
        if distance < ennemies.body.attack_range then
            drone.state = droneState.ATTACKING
        elseif distance > 500 then
            drone.state = droneState.IDLE
        end
    elseif drone.state == droneState.ATTACKING then
        if distance > ennemies.body.attack_range then
            drone.state = droneState.CHASING
        end
    end

    return distance, tank.position.x, tank.position.y
end

--respawn des drones
ennemies.update = function(dt)
    for i = #drones, 1, -1 do
        local drone = drones[i]
        local distance, targetX, targetY = updateDroneState(drone)

        if drone.state == droneState.IDLE then
            drone.timer = drone.timer - dt
            if drone.timer <= 0 then
                drone.angle = math.random(0, 2 * math.pi)
                drone.timer = math.random(1, 3)
            end
            drone.x = drone.x + math.cos(drone.angle) * drone.speed * dt
            drone.y = drone.y + math.sin(drone.angle) * drone.speed * dt
        end

        if drone.state == droneState.CHASING or drone.state == droneState.ATTACKING then
            local angle = math.atan2(targetY - drone.y, targetX - drone.x)
            drone.x = drone.x + math.cos(angle) * drone.speed * dt
            drone.y = drone.y + math.sin(angle) * drone.speed * dt
            drone.angle = angle
        end

        if drone.state == droneState.ATTACKING and distance < 50 then
            drone.hit = true
        end

        if drone.hit then
            tank.body.vie = tank.body.vie - ennemies.body.drone_damage
            drone.vie = drone.vie - 50 
            drone.hit = false
        end

        if drone.state == droneState.ATTACKING or drone.state == droneState.CHASING or drone.state == droneState.IDLE then
            drone.x = math.max(0, math.min(SCREEN_SIZE.width, drone.x))
            drone.y = math.max(0, math.min(SCREEN_SIZE.height, drone.y))
        end

        if drone.state == droneState.DEAD then
            table.remove(drones, i)
            local tankPos = ennemies.tankBody and ennemies.tankBody.position
            if tankPos then
            local radius = math.random(200, 500)
            local angle = math.random() * 2 * math.pi
            local x = ennemies.tankBody.position.x + math.cos(angle) * radius
            local y = ennemies.tankBody.position.y + math.sin(angle) * radius
            ennemies.spawn(x, y)
            end
        end
    end
end

ennemies.draw = function()
    for _, drone in ipairs(drones) do
        love.graphics.draw(
            drone.img,
            drone.x, drone.y,
            drone.angle,
            drone.size, drone.size,
            drone.img:getWidth() / 2, drone.img:getHeight() / 2
        )

        local hpBarWidth = 50
        local hpBarHeight = 5
        local hpBarX = drone.x - hpBarWidth / 2
        local hpBarY = drone.y - drone.img:getHeight() / 2 - hpBarHeight - 5

        local hpMax = ennemies.body.drone_vie
        local hpRatio = math.max(0, drone.vie) / hpMax

        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarWidth, hpBarHeight)

        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarWidth * hpRatio, hpBarHeight)

        love.graphics.setColor(1, 1, 1)

        --love.graphics.rectangle("line", drone.x - drone.img:getWidth() / 2, drone.y - drone.img:getHeight() / 2, drone.img:getWidth(), drone.img:getHeight())
        
    end
end

return ennemies