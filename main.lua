-- Princess Sparkle Pong | LÖVE2D 11.x
-- Main gameplay: paddles, ball movement, AABB collision, scores, winning.
-- Art and particles: effects.lua | Menu, scoreboard and winner: screens.lua

local Effects = require("effects")
local Screens = require("screens")

local WIDTH, HEIGHT = 800, 600
local PADDLE_WIDTH, PADDLE_HEIGHT = 20, 100
local BALL_SIZE = 24
local BALL_START_SPEED = 200
local MAX_BALL_SPEED = 520
local WIN_SCORE = 5

local gameState = "welcome" -- welcome / playing / paused / winner
local winner = nil

-- Ball and paddles remain simple Lua tables as requested in Task 1 and Task 2.
local player1, player2, ball
local score1, score2 = 0, 0

-- Task 2: axis-aligned bounding box (AABB) rectangle collision.
-- The heart's collision box is still BALL_SIZE x BALL_SIZE.
local function checkCollision(b, paddle)
    return b.x <= paddle.x + paddle.width and
           b.x + b.size >= paddle.x and
           b.y <= paddle.y + paddle.height and
           b.y + b.size >= paddle.y
end

local function resetBall()
    ball.x = WIDTH / 2 - ball.size / 2
    ball.y = HEIGHT / 2 - ball.size / 2
    ball.dx = BALL_START_SPEED * (math.random(2) == 1 and 1 or -1)
    ball.dy = BALL_START_SPEED * (math.random(2) == 1 and 1 or -1)
    Effects.resetTrail()
end

local function startMatch()
    score1, score2 = 0, 0
    winner = nil
    player1.y = (HEIGHT - player1.height) / 2
    player2.y = (HEIGHT - player2.height) / 2
    Effects.clearParticles()
    resetBall()
    gameState = "playing"
end

function love.load()
    love.window.setTitle("Princess Sparkle Pong")
    love.window.setMode(WIDTH, HEIGHT)
    love.graphics.setBackgroundColor(0.12, 0.07, 0.20)
    math.randomseed(os.time())

    -- Task 1: paddle positions, dimensions and speed stored in Lua tables.
    player1 = {
        x = 50, y = 240,
        width = PADDLE_WIDTH, height = PADDLE_HEIGHT, speed = 300
    }
    player2 = {
        x = WIDTH - 50 - PADDLE_WIDTH, y = 250,
        width = PADDLE_WIDTH, height = PADDLE_HEIGHT, speed = 300
    }

    -- Task 2: ball starts in the center and has x/y velocities.
    ball = {
        x = WIDTH / 2 - BALL_SIZE / 2,
        y = HEIGHT / 2 - BALL_SIZE / 2,
        size = BALL_SIZE, dx = BALL_START_SPEED, dy = BALL_START_SPEED
    }

    score1, score2 = 0, 0
    Effects.init(WIDTH, HEIGHT)
    Screens.init(WIDTH, HEIGHT, WIN_SCORE)
end

function love.keypressed(key)
    if key == "space" then
        if gameState == "welcome" or gameState == "winner" then
            startMatch()
        elseif gameState == "paused" then
            gameState = "playing"
        end
    elseif key == "p" then
        if gameState == "playing" then
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "playing"
        end
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    -- Avoid skipping through narrow paddles after a long interrupted frame.
    dt = math.min(dt, 0.08)
    Effects.update(dt)

    -- No gameplay movement on welcome, pause, or winner screens.
    if gameState ~= "playing" then
        return
    end

    -- Task 1: paddle movement (W/S and Up/Down) using delta time.
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    elseif love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    elseif love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Keep both paddles inside the screen.
    player1.y = math.max(0, math.min(player1.y, HEIGHT - player1.height))
    player2.y = math.max(0, math.min(player2.y, HEIGHT - player2.height))

    -- Task 2: update ball position using horizontal/vertical velocity and dt.
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
    Effects.emitTrail(ball, dt)

    -- Bounce off the top and bottom walls; correct position after impact.
    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy
        Effects.magicHit(ball.x + ball.size / 2, 0, Effects.colors.lavender)
    elseif ball.y + ball.size >= HEIGHT then
        ball.y = HEIGHT - ball.size
        ball.dy = -ball.dy
        Effects.magicHit(ball.x + ball.size / 2, HEIGHT, Effects.colors.lavender)
    end

    -- Bounce off paddles, accelerate 5%, and prevent overlapping/sticking.
    if ball.dx < 0 and checkCollision(ball, player1) then
        ball.x = player1.x + player1.width
        ball.dx = math.min(math.abs(ball.dx) * 1.05, MAX_BALL_SPEED)
        Effects.magicHit(ball.x, ball.y + ball.size / 2, Effects.colors.pink)
    elseif ball.dx > 0 and checkCollision(ball, player2) then
        ball.x = player2.x - ball.size
        ball.dx = -math.min(math.abs(ball.dx) * 1.05, MAX_BALL_SPEED)
        Effects.magicHit(ball.x + ball.size, ball.y + ball.size / 2, Effects.colors.purple)
    end

    -- A point is awarded when the whole ball leaves a side.
    if ball.x + ball.size < 0 then
        score2 = score2 + 1
        resetBall()
        if score2 >= WIN_SCORE then
            winner = 2
            gameState = "winner"
        end
    elseif ball.x > WIDTH then
        score1 = score1 + 1
        resetBall()
        if score1 >= WIN_SCORE then
            winner = 1
            gameState = "winner"
        end
    end
end

function love.draw()
    Effects.drawBackground()
    Screens.drawPlayfield(player1, player2, ball, score1, score2)
    Screens.drawOverlay(gameState, winner, score1, score2)
end
