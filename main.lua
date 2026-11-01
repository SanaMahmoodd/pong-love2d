function love.load()
    love.window.setTitle("Pong Game")
    love.window.setMode(800, 600) -- Width X Height

    -- Paddle and ball constants
    local PADDLE_WIDTH = 20
    local PADDLE_HEIGHT = 100
    local BALL_SIZE = 20

    -- Left paddle
    player1 = {
        x = 50,
        y = 240,
        width = PADDLE_WIDTH,
        height = PADDLE_HEIGHT,
        speed = 300
    }

    -- Right paddle
    player2 = {
        x = 800 - 50 - PADDLE_WIDTH,
        y = 250,
        width = PADDLE_WIDTH,
        height = PADDLE_HEIGHT,
        speed = 300
    }

    -- Ball
    ball = {
        x = 400 - BALL_SIZE / 2,
        y = 300 - BALL_SIZE / 2,
        size = BALL_SIZE
    }
end


function love.draw()
    -- Set background color
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    -- Draw the dashed line at center
    love.graphics.setColor(1, 1, 1)

    for i = 0, 600, 30 do
        love.graphics.rectangle("fill", 395, i, 10, 15)
    end

    -- Draw paddles
    love.graphics.rectangle("fill",
        player1.x, player1.y,
        player1.width, player1.height)

    love.graphics.rectangle("fill",
        player2.x, player2.y,
        player2.width, player2.height)

    -- Draw ball
    love.graphics.rectangle("fill",
        ball.x, ball.y,
        ball.size, ball.size)
end


function love.update(dt)

    -- Left paddle (Player 1)
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    elseif love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    -- Right paddle (Player 2)
    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    elseif love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Prevent paddles from leaving screen
    local screenHeight = love.graphics.getHeight()

    player1.y = math.max(0,
        math.min(player1.y, screenHeight - player1.height))

    player2.y = math.max(0,
        math.min(player2.y, screenHeight - player2.height))

end