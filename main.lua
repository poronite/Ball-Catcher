function love.load()
    titleFont = love.graphics.newFont(50)
    menuFont = love.graphics.newFont(30)
    gameFont = love.graphics.newFont(40)

    love.window.setMode(0, 0)

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    gameState = "MainMenu"

    timeLeftGame = 10
    gameTimer = timeLeftGame

    score = 0
    numMissClicks = 0

    maxNumTargets = 15
    minNumTargets = 1
    numTargets = minNumTargets
    currentNumTargets = numTargets
    maxTargetsSpeed = 4
    targetsSpeed = 0
    targetsRadius = 50
    targets = {}
end


function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.window.close()
    end

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    if gameState == "Gameplay" then
        gameTimer = gameTimer - love.timer.getDelta()

        if gameTimer <= 0 then
            gameState = "MainMenu"
        end

        for i = 1, currentNumTargets, 1 do
            targets[i].x = targets[i].x + (targets[i].directionX * targets[i].velocity * targetsSpeed * dt)
            targets[i].y = targets[i].y + (targets[i].directionY * targets[i].velocity * targetsSpeed * dt)
    
            if targets[i].x < -targetsRadius then
                targets[i].x = love.graphics.getWidth() + targetsRadius
            end
    
            if targets[i].x > love.graphics.getWidth() + targetsRadius then
                targets[i].x = -targetsRadius
            end
    
            if targets[i].y < -targetsRadius then
                targets[i].y = love.graphics.getHeight() + targetsRadius
            end
    
            if targets[i].y > love.graphics.getHeight() + targetsRadius then
                targets[i].y = -targetsRadius
            end
        end
    else

    end

    
end


function love.draw()
    if gameState == "Gameplay" then
        love.graphics.setColor(1, 0, 0)
        for i = 1, currentNumTargets, 1 do
            love.graphics.circle("fill", targets[i].x, targets[i].y, targets[i].radius)                       
        end
    
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(gameFont)
        drawCenteredText("Time Left: " .. math.floor(gameTimer * 10) / 10, gameFont, screenWidth / 3, screenHeight - 40)
        drawCenteredText("Targets Left: " .. currentNumTargets, gameFont, screenWidth / 3 * 2, screenHeight - 40)
    elseif gameState == "MainMenu" then
        if score > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(menuFont)
            drawCenteredText("Last score: " .. score, menuFont, screenWidth / 3, screenHeight / 4)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(menuFont)
            drawCenteredText("Number of miss clicks: " .. numMissClicks, menuFont, screenWidth / 3 * 2, screenHeight / 4)            
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(titleFont)
        drawCenteredText("Ball Catcher", titleFont, screenWidth / 2, screenHeight / 2 - 100)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(menuFont)
        drawCenteredText("Press Left Mouse Button to start game", menuFont, screenWidth / 2, screenHeight / 2 + 200)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(menuFont)
        drawCenteredText("Press Esc at any time to exit game", menuFont, screenWidth / 2, screenHeight - 40)
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "Gameplay" then
        if button == 1 then
            local targetToRemove = -1
            local mouseToTarget
            for i = 1, currentNumTargets, 1 do
                mouseToTarget = distanceBetween(x, y, targets[i].x, targets[i].y)
    
                if mouseToTarget < targets[i].radius then
                    score = score + 1
                    targetToRemove = i
                    speedUpTargets()
                    addTarget()
                    break
                else
                    numMissClicks = numMissClicks + 1
                end            
            end
            
            if targetToRemove ~= -1 then
                currentNumTargets = currentNumTargets - 1
                table.remove(targets, targetToRemove)
            end
            
            if currentNumTargets == 0 then
                spawnTargets()
            end
        end
    elseif gameState == "MainMenu" then
        gameState = "Gameplay"        
        score = 0
        numMissClicks = 0
        numTargets = minNumTargets
        spawnTargets()
    end    
end



function speedUpTargets()
    if targetsSpeed < maxTargetsSpeed and math.fmod(score, 3) == 0 then
        targetsSpeed = targetsSpeed + 1  
    end
end

function addTarget()
    if numTargets < maxNumTargets and math.fmod(score, 5) == 0  then
        numTargets = numTargets + 1
    end
end

function spawnTargets()
    gameTimer = timeLeftGame
    currentNumTargets = numTargets

    for i = 1, currentNumTargets, 1 do
        table.insert(targets, i, {
            x = love.math.random(targetsRadius, love.graphics.getWidth() - targetsRadius), 
            y = love.math.random(targetsRadius, love.graphics.getHeight() - targetsRadius), 
            radius = targetsRadius, 
            velocity = love.math.random(0, 100), 
            directionX = love.math.random(0, 1), 
            directionY = love.math.random(0, 1)
        })
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) )
end


function drawCenteredText(text, usedFont, posX, posY)
	local font       = usedFont
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, posX, posY, 0, 1, 1, textWidth/2, textHeight/2)
end